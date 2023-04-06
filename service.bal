import ballerina/http;
import ballerina/regex;

type WifiPayload readonly & record {|
    string username;
    string email;
    string password;
|};

type WifiPayloadRecord record {|
    readonly string email;
    WifiPayload[] wifiAccounts;
|};


// map<WifiPayloadRecord[]> wifiAccounts = {

// }

table<WifiPayloadRecord> key(email) wifiAccounts = table [
    {email: "nadheesh@wso2.com", wifiAccounts: [{email: "nadheesh@wso2.com", username: "newuser", password: "newpass"}]},
    {email: "malithj@wso2.com", wifiAccounts: [{email: "malithj@wso2.com", username: "malith", password: "malithpass"}]}
];



// table<WifiPayload> key(email) wifiAccounts = table [
//     {email: "nadheesh@wso2.com", wifiAccounts: [{email: "nadheesh@wso2.com", username: "newuser", password: "newpass"}]},
//     {email: "malithj@wso2.com", wifiAccounts: [{email: "malithj@wso2.com", username: "malith", password: "malithpass"}]}
// ];



service / on new http:Listener(9090) {

    resource function get guest\-wifi\-accounts/[string ownerEmail]() returns string[] {
        WifiPayloadRecord wifiRecords = wifiAccounts.get(ownerEmail);
        string[] payload = [];
        foreach WifiPayload wifiAccount in wifiRecords.wifiAccounts {
            if (wifiAccount.email == ownerEmail) {
                payload.push(string`${wifiAccount.username}.guestOf.${regex:split(ownerEmail, "@")[0]}`);
            }
        }
        return payload;
    }

    resource function post guest\-wifi\-accounts(@http:Payload WifiPayload wifiRecord) returns string {
        
        if (wifiRecord.hasKey("email")) {
            wifiAccounts.add({email: wifiRecord.email, wifiAccounts: [wifiRecord]});
        } else {
            WifiPayloadRecord wifiRecords = wifiAccounts.get(wifiRecord.email);
            wifiRecords.wifiAccounts.push(wifiRecord);
        }
        return "Successfully added the wifi account";
    }
}