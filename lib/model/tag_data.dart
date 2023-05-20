class TagData{
  late String key;
  late String createDate;

  TagData(Map<dynamic, dynamic> map, this.key){
    createDate = map['createDate'];
  }
}