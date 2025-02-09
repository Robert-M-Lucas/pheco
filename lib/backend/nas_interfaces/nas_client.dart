abstract class NasClient {
  Future<String?> testConnection();
}

const List<String> protocolOptions = ['SFTP', 'SMB'];

NasClient getNasInterface(String nasType, String localIp, String publicIp, String serverFolder, String username, String? password) {


  throw UnimplementedError();
}