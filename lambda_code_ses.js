var aws = require("aws-sdk");
var ses = new aws.SES({ region: "us-east-1" });
exports.handler = async function (event) {
  var params = {
    Destination: {
      ToAddresses: ["eng.abdelrahman.mostafa.ali@gmail.com"]
    },
    Message: {
      Body: {
        Text: { Data: "the statefile has been updated " },
      },

      Subject: { Data: "statefile update" },
    },
    Source: "am849171@gmail.com"
  };
 
  return ses.sendEmail(params).promise()
};