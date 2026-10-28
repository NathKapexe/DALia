/// Reference to a photo taken by the user.
///
/// The domain only knows the path. Reading or uploading the file is the job
/// of the data layer.
class PlantPhoto {
  const PlantPhoto(this.path);

  final String path;
}
