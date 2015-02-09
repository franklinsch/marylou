package bloomberg_request;

import java.io.PrintWriter;
import java.util.Map;

public class GenerateJSON {

  public static void getJSON(String[] s, String[] vals, String filepath) throws Exception {
    StringBuilder ja = new StringBuilder();
    ja.append("{ \"securities\": [");
    for (int i = 0; i < s.length; i++) {
      ja.append("\"" + s[i] + "\"");
      if (i + 1 != s.length)
        ja.append(", ");
    }
    ja.append("]," +
        "\"fields\": [");
    for (int i = 0; i < vals.length; i++) {
      ja.append("\"" + vals[i] + "\"");
      if (i + 1 != vals.length)
        ja.append(", ");
    }
    ja.append("],"  +                                                       
        "\"startDate\": \"20140101\"," +                                                      
        "\"endDate\": \"20150101\"," +                                                        
        "\"periodicitySelection\": \"MONTHLY\" }");
    PrintWriter out = new PrintWriter(filepath);
    out.println(ja.toString());
    out.close();
  }

  public static String sendJSON(Map<Integer, BloombergObject> data) {
    StringBuilder out = new StringBuilder();
    out.append("[\n");
    int count = 0;
    for (Map.Entry<Integer, BloombergObject> pair : data.entrySet()) {
      out.append("{\n");
      out.append("\"city\" : \"" + pair.getValue().getRelationName() + "\",\n");
      out.append("\"geo\" : \"" + pair.getValue().getGeoLocation() + "\"");
      out.append("}\n");
      if (count + 1 != data.size()) out.append(",\n");
      count++;
    }
    out.append("\n]");
    return out.toString();
  }
  
}
