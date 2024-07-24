class PredictedPlacesModel {
  String? description;
  List<MatchedSubstring>? matchedSubstrings;
  String? placeId;
  String? reference;

  List<Term>? terms;
  List<String>? types;

  PredictedPlacesModel({
    required this.description,
    required this.matchedSubstrings,
    required this.placeId,
    required this.reference,
    required this.terms,
    required this.types,
  });

  factory PredictedPlacesModel.fromJson(Map<String, dynamic> json) {
    return PredictedPlacesModel(
      description: json['description'],
      matchedSubstrings: List<MatchedSubstring>.from(
          json['matched_substrings'].map((x) => MatchedSubstring.fromJson(x))),
      placeId: json['place_id'],
      reference: json['reference'],
      terms: List<Term>.from(json['terms'].map((x) => Term.fromJson(x))),
      types: List<String>.from(json['types'].map((x) => x)),
    );
  }
}

class MatchedSubstring {
  final int length;
  final int offset;

  MatchedSubstring({
    required this.length,
    required this.offset,
  });

  factory MatchedSubstring.fromJson(Map<String, dynamic> json) {
    return MatchedSubstring(
      length: json['length'],
      offset: json['offset'],
    );
  }
}

class Term {
  final int offset;
  final String value;

  Term({
    required this.offset,
    required this.value,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      offset: json['offset'],
      value: json['value'],
    );
  }
}
