package bloomberg_request;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class BloombergObject {

  private String securityName;
  private String geoLocation;
  //private Map<String, Object> dataSources;
  private double averagePrice;
  private String relationName;
  private int score;
  
  public BloombergObject(String relationName, String securityName, String geoLocation
      , JSONArray fielddata) throws JSONException {
    this.relationName = relationName;
    this.securityName = securityName;
    this.geoLocation = geoLocation;
    // TODO Implement using dataSources to store the available
    //      for the algorithm.
    this.averagePrice = parsePrice(fielddata); // Temporary sole data source.
  }
  
  public double parsePrice(JSONArray data) throws JSONException {
    double output = 0.0;
    for (int i = 0; i < data.length(); i++) {
      output += (double) ((JSONObject) data.get(i)).get("PX_MID");
    }
    return output / data.length();
  }
  
  public String getRelationName() {
    return relationName;
  }
  
  public String getsecurityName() {
    return securityName;
  }
  
  public String getGeoLocation() {
    return geoLocation;
  }
  
  public double getScore() {
    score = (int) averagePrice; // Whilst <dataSources>.length == 1
    return score;
  }

  public String toString() {
    StringBuilder out = new StringBuilder();
    out.append("Security Name:\t" + securityName + "\n"
        + "Relation Name:\t" + relationName + "\n"
        + "Average Price:\t" + averagePrice);
    return out.toString();
  }

}
