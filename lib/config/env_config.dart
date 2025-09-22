import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl {
    return dotenv.env['SUPABASE_URL'] ?? 
           'https://qzkdirgocngvylcowfnj.supabase.co';
  }
  
  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ?? 
           'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF6a2RpcmdvY25ndnlsY293Zm5qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM0NDExNDIsImV4cCI6MjA2OTAxNzE0Mn0.WRrFY4wBpdMfOzKKpA1jDmEhTBx8EZBO0Eqzh9uIs_A';
  }
  
  static String get supabaseServiceRoleKey {
    return dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  }
  
  static String get bucketName {
    return dotenv.env['BUCKET_NAME'] ?? 'html-files';
  }
  
  static String get folderName {
    return dotenv.env['FOLDER_NAME'] ?? 'health_info';
  }

  static String get hcaptchaSiteKey {
    return dotenv.env['HCAPTCHA_SITE_KEY'] ?? '';
  }
}
