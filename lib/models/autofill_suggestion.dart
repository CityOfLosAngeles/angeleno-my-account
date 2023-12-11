class AutofillSuggestion {
  final String placeId;
  final String description;

  AutofillSuggestion(this.placeId, this.description);

  @override
  String toString() =>
      'AutofillSuggestion(description: $description, placeId: $placeId)';
}
