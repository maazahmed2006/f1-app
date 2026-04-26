class CircuitModel{
   final double xPosition ;
   final double yPosition ;

  CircuitModel({
    required this.xPosition ,
    required this.yPosition ,
});


  factory CircuitModel.fromJson (Map<String , dynamic>  json)
  {
    return CircuitModel(
        xPosition: (json['X'] as num).toDouble()
      ,
        yPosition: (json['Y'] as num).toDouble(),
    );
  }
}
