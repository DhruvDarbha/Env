import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import os
from supabase import create_client, Client
import json
from flask import Flask, send_file, jsonify
from flask_cors import CORS
import io
import base64

# Supabase configuration
SUPABASE_URL = "https://tjpilnhmtwjvhmbaxtcx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqcGlsbmhtdHdqdmhtYmF4dGN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzODQwNDcsImV4cCI6MjA3Mzk2MDA0N30.QXd4er8enrzcDXZPJSts3qfm63IW-ZZsQ8UywbsWuog"

app = Flask(__name__)
CORS(app)

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_table_name_from_email(email):
    """Extract table name from supplier email (e.g., sunkist@env.com -> sunkist_data)"""
    username = email.split('@')[0].lower()
    return f"{username}_data"

def get_supplier_data(table_name):
    """Fetch data from Supabase table"""
    try:
        response = supabase.table(table_name).select("*").order("analyzed_at", desc=False).execute()
        if response.data:
            print(f"Found {len(response.data)} records in {table_name}")
            return response.data
        else:
            print(f"No data in {table_name}, trying halos_data as fallback...")
            # Fallback to halos_data if the requested table is empty
            fallback_response = supabase.table("halos_data").select("*").order("analyzed_at", desc=False).execute()
            print(f"Using {len(fallback_response.data)} records from halos_data")
            return fallback_response.data
    except Exception as e:
        print(f"Error fetching data from {table_name}: {e}")
        # Try halos_data as fallback
        try:
            print(f"Trying halos_data as fallback...")
            fallback_response = supabase.table("halos_data").select("*").order("analyzed_at", desc=False).execute()
            print(f"Using {len(fallback_response.data)} records from halos_data")
            return fallback_response.data
        except Exception as fallback_error:
            print(f"Fallback also failed: {fallback_error}")
            return []

def convert_ripeness_to_shelf_life(ripeness_score):
    """Convert ripeness score to estimated shelf life"""
    if ripeness_score <= 3:
        return 1.5  # Very ripe: 1-2 days
    elif ripeness_score <= 7:
        return 4.0  # Just ripe: 3-5 days
    else:
        return 8.0  # Unripe: 6-10 days

@app.route('/generate_ripeness_chart/<supplier_email>')
def generate_ripeness_chart(supplier_email):
    """Generate ripeness scores over time chart"""
    try:
        table_name = get_table_name_from_email(supplier_email)
        data = get_supplier_data(table_name)

        if not data:
            return jsonify({"error": "No data found"}), 404

        # Prepare data
        dates = []
        ripeness_scores = []

        for item in data:
            if item.get('analyzed_at') and item.get('ripeness_score'):
                dates.append(datetime.fromisoformat(item['analyzed_at'].replace('Z', '+00:00')))
                ripeness_scores.append(float(item['ripeness_score']))

        if not dates:
            return jsonify({"error": "No valid data points"}), 404

        # Create the plot
        plt.figure(figsize=(12, 6))
        plt.plot(dates, ripeness_scores, marker='o', linewidth=2, markersize=6, color='#FF6B35')

        # Customize the plot
        plt.title(f'Ripeness Scores Over Time - {supplier_email.split("@")[0].title()}',
                 fontsize=16, fontweight='bold', pad=20)
        plt.xlabel('Date', fontsize=12)
        plt.ylabel('Ripeness Score', fontsize=12)
        plt.grid(True, alpha=0.3)

        # Color zones
        plt.axhspan(0, 3, alpha=0.2, color='red', label='Very Ripe (0-3)')
        plt.axhspan(3, 7, alpha=0.2, color='orange', label='Just Ripe (3-7)')
        plt.axhspan(7, 15, alpha=0.2, color='green', label='Unripe (7-15)')

        plt.legend(loc='upper right')
        plt.ylim(0, 15)

        # Format x-axis
        plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
        plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
        plt.xticks(rotation=45)

        plt.tight_layout()

        # Save to bytes
        img_buffer = io.BytesIO()
        plt.savefig(img_buffer, format='png', dpi=150, bbox_inches='tight')
        img_buffer.seek(0)
        plt.close()

        return send_file(img_buffer, mimetype='image/png')

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/generate_shelf_life_chart/<supplier_email>')
def generate_shelf_life_chart(supplier_email):
    """Generate average shelf life over time chart"""
    try:
        table_name = get_table_name_from_email(supplier_email)
        data = get_supplier_data(table_name)

        if not data:
            return jsonify({"error": "No data found"}), 404

        # Group data by date and calculate average shelf life
        daily_shelf_life = {}

        for item in data:
            if item.get('analyzed_at') and item.get('ripeness_score'):
                date = datetime.fromisoformat(item['analyzed_at'].replace('Z', '+00:00')).date()
                ripeness_score = float(item['ripeness_score'])
                shelf_life = convert_ripeness_to_shelf_life(ripeness_score)

                if date not in daily_shelf_life:
                    daily_shelf_life[date] = []
                daily_shelf_life[date].append(shelf_life)

        if not daily_shelf_life:
            return jsonify({"error": "No valid data points"}), 404

        # Calculate averages
        dates = sorted(daily_shelf_life.keys())
        avg_shelf_life = [np.mean(daily_shelf_life[date]) for date in dates]

        # Create the plot
        plt.figure(figsize=(12, 6))
        plt.plot(dates, avg_shelf_life, marker='o', linewidth=3, markersize=8,
                color='#4A90E2', markerfacecolor='white', markeredgewidth=2)
        plt.fill_between(dates, avg_shelf_life, alpha=0.3, color='#4A90E2')

        # Customize the plot
        plt.title(f'Average Shelf Life Over Time - {supplier_email.split("@")[0].title()}',
                 fontsize=16, fontweight='bold', pad=20)
        plt.xlabel('Date', fontsize=12)
        plt.ylabel('Average Shelf Life (Days)', fontsize=12)
        plt.grid(True, alpha=0.3)

        # Add value labels on points
        for i, (date, shelf_life) in enumerate(zip(dates, avg_shelf_life)):
            plt.annotate(f'{shelf_life:.1f}', (date, shelf_life),
                        textcoords="offset points", xytext=(0,10), ha='center', fontsize=9)

        plt.ylim(0, max(avg_shelf_life) * 1.2)

        # Format x-axis
        plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d'))
        plt.gca().xaxis.set_major_locator(mdates.DayLocator(interval=1))
        plt.xticks(rotation=45)

        plt.tight_layout()

        # Save to bytes
        img_buffer = io.BytesIO()
        plt.savefig(img_buffer, format='png', dpi=150, bbox_inches='tight')
        img_buffer.seek(0)
        plt.close()

        return send_file(img_buffer, mimetype='image/png')

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/supplier_summary/<supplier_email>')
def get_supplier_summary(supplier_email):
    """Get supplier summary statistics"""
    try:
        table_name = get_table_name_from_email(supplier_email)
        data = get_supplier_data(table_name)

        if not data:
            return jsonify({"error": "No data found"}), 404

        # Calculate statistics
        ripeness_scores = [float(item['ripeness_score']) for item in data if item.get('ripeness_score')]

        if not ripeness_scores:
            return jsonify({"error": "No valid ripeness scores"}), 404

        avg_ripeness = np.mean(ripeness_scores)
        avg_shelf_life = convert_ripeness_to_shelf_life(avg_ripeness)

        # Determine quality grade
        if avg_ripeness >= 7:
            quality_grade = 'Excellent'
        elif avg_ripeness >= 4:
            quality_grade = 'Good'
        else:
            quality_grade = 'Needs Attention'

        return jsonify({
            'total_analyses': len(data),
            'average_ripeness': round(avg_ripeness, 2),
            'average_shelf_life': round(avg_shelf_life, 1),
            'quality_grade': quality_grade,
            'latest_entry': data[-1]['analyzed_at'] if data else None
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/health')
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "chart_generator"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)