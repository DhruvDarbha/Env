class RipenessDataPoint {
  final DateTime date;
  final double ripenessScore;

  RipenessDataPoint({
    required this.date,
    required this.ripenessScore,
  });
}

class ShelfLifeDataPoint {
  final DateTime date;
  final double averageShelfLife;

  ShelfLifeDataPoint({
    required this.date,
    required this.averageShelfLife,
  });
}

class SupplierSummary {
  final int totalAnalyses;
  final double averageRipeness;
  final double averageShelfLife;
  final String qualityGrade;

  SupplierSummary({
    required this.totalAnalyses,
    required this.averageRipeness,
    required this.averageShelfLife,
    required this.qualityGrade,
  });
}