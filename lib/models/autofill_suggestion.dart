class AutofillSuggestion {
  final String placeId;
  final String description;
  final String streetAddress;

  AutofillSuggestion(this.placeId, this.description, this.streetAddress);

  @override
  // ignore: lines_longer_than_80_chars
  String toString() =>
      'AutofillSuggestion(description: $description, placeId: $placeId, streetAddress: $streetAddress)';
}
