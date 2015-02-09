package bloomberg_request;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class BloombergUtils {

  public static String getData(String bloomberg_cert, String personal_cert, 
      String personal_key, String request) throws IOException {
    ProcessBuilder proc = new ProcessBuilder("curl", "-X", "POST"
        , "https://http-api.openbloomberg.com/request/blp/refdata/HistoricalData", "--cacert" 
        , bloomberg_cert, "--cert", personal_cert, "--key", personal_key, "--data", "@" + request + "");
    Process p = proc.start();
    BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
    StringBuilder builder = new StringBuilder();
    String line = null;
    while ( (line = reader.readLine()) != null) {
      builder.append(line);
      builder.append("\n");
    }
    String jsonString = builder.toString();
    return jsonString;
  }
  
  public static String fileToString (FileReader file) throws IOException{
      BufferedReader br = new BufferedReader(file);
          StringBuilder sb = new StringBuilder();
          String line = br.readLine();

          while (line != null) {
              sb.append(line);
              sb.append(System.lineSeparator());
              line = br.readLine();
          }
          String everything = sb.toString();
          return everything;
  }
}
