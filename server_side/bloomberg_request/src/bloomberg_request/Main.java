package bloomberg_request;

import java.io.File;
import java.io.FileReader;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;
import java.util.UUID;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Main {

  /**
   * @param arg0 : CACERT
   * @param arg1 : CERT
   * @param arg2 : KEY
   * @param arg3 : REQUEST
   * @param arg4 : FILEOUT
   * @throws JSONException 
   */
  public static void main(String[] args) throws Exception {

    String country        = args[0]; 
    String folder         = "/home/fl1414/Downloads/ICHack15/";
    //String folder         = "/home/ubuntu/";
    String bloomberg_cert = folder + "marylou/api_access/bloomberg.crt";
    String personal_cert  = folder + "marylou/api_access/client.crt";
    String personal_key   = folder + "marylou/api_access/client.key";

    String citiesJSON     = folder + "marylou//api_access/cities.json";
    FileReader city_mappings = new FileReader(citiesJSON);
    JSONArray mapping_input = new JSONArray(BloombergUtils.fileToString(city_mappings));

    Map<String, JSONObject> relevant_cities = new HashMap<>();
    for (int i = 0; i < mapping_input.length(); i++) {
      try {
        if (country.equals(mapping_input.getJSONObject(i).get("country")))
          relevant_cities.put((String) mapping_input.getJSONObject(i).get("index"),
                              mapping_input.getJSONObject(i));
      } catch (Exception e) {
        e.printStackTrace();
      }
    }
    
    String[] relevant_cities_index = new String[relevant_cities.size()];
    String[] relevant_cities_names = new String[relevant_cities.size()];
    String[] relevant_geo_index    = new String[relevant_cities.size()];
    int noob = 0;
    for (Map.Entry<String, JSONObject> pair : relevant_cities.entrySet()) {
      relevant_cities_index[noob] = pair.getKey();
      relevant_cities_names[noob] = (String) pair.getValue().get("city");
      relevant_geo_index[noob] = (String) pair.getValue().get("geo");
      noob++;
    }

    String[] parameters = new String[args.length - 1];
    for (int i = 1; i < args.length; i++) {
      parameters[i-1] = args[i];
    }
    String uuid = UUID.randomUUID().toString();
    String request        = folder + "marylou/api_access/request" + uuid + ".json";
    
    GenerateJSON.getJSON(relevant_cities_index, parameters, request);
    String jsonString = BloombergUtils.getData(bloomberg_cert, personal_cert, 
        personal_key, request);
    System.out.println(jsonString);
    new File(request).delete();
    
    JSONObject json = new JSONObject(jsonString);
    JSONArray dataArray = (JSONArray) json.get("data");
    Map<Integer, BloombergObject> securityData = new HashMap<>();
    for (int i = 0; i < dataArray.length(); i++) {
      try {
        JSONObject data =  (dataArray.getJSONObject(i)).getJSONObject("securityData");
        BloombergObject temp = new BloombergObject(relevant_cities_names[i]
            , (String) data.get("security"), relevant_geo_index[i], (JSONArray) data.get("fieldData"));
        securityData.put(Integer.valueOf((int) temp.getScore()), temp);
      } catch (Exception e) {
      }
    }
    Map<Integer, BloombergObject> sortedData = new TreeMap<>(securityData);
    System.out.println(GenerateJSON.sendJSON(sortedData));
  }
}
