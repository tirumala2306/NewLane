part of 'training_bloc.dart';

sealed class TrainingState extends Equatable {
  const TrainingState();

  @override
  List<Object?> get props => <Object?>[];
}

class TrainingInitial extends TrainingState {
  const TrainingInitial();
}

class TrainingLoading extends TrainingState {
  const TrainingLoading();
}

class TrainingLoaded extends TrainingState {
  const TrainingLoaded({required this.resources});

  final List<TrainingResource> resources;

  List<TrainingResource> byCategory(String apiCategory) {
    final String needle = apiCategory.trim().toLowerCase();
    if (needle.isEmpty) return const <TrainingResource>[];

    final List<TrainingResource> exact = resources
        .where(
          (TrainingResource r) => r.category.trim().toLowerCase() == needle,
        )
        .toList();
    if (exact.isNotEmpty) return exact;

    // Soft match: "Video" ↔ "Videos", "PDF" ↔ "PDFs", etc.
    final String singular = needle.endsWith('s') && needle.length > 1
        ? needle.substring(0, needle.length - 1)
        : needle;
    return resources.where((TrainingResource r) {
      final String cat = r.category.trim().toLowerCase();
      if (cat.isEmpty) return false;
      if (cat == singular || cat == '${singular}s') return true;
      return cat.contains(needle) || needle.contains(cat);
    }).toList();
  }

  List<TrainingResource> get featured => resources
      .where((TrainingResource r) => r.isFeatured)
      .toList();

  List<TrainingResource> get downloads {
    final List<TrainingResource> pdfs = byCategory('PDF');
    if (pdfs.isNotEmpty) return pdfs;
    return resources.where((TrainingResource r) => r.isPdf).toList();
  }

  int countFor(String apiCategory) => byCategory(apiCategory).length;

  @override
  List<Object?> get props => <Object?>[resources];
}

class TrainingError extends TrainingState {
  const TrainingError(this.message);

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}
