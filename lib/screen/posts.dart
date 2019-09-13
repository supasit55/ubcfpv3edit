class Posts {
  String image,
      description,
      date,
      time,
      shopname,
      logo,
      loneDescription,
      key,
      locationName;
  double lat, lng;

  Posts(
    this.image,
    this.description,
    this.date,
    this.time,
    this.shopname,
    this.logo,
    this.lat,
    this.lng,
    this.loneDescription, {
    this.key,
    this.locationName,
  });
}
