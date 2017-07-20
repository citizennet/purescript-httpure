"use strict";

exports.mockRequest = function(method) {
  return function(url) {
    return function(body) {
      return function(headers) {
        return function() {
          var stream = new require('stream').Readable({
            read: function(size) {
              this.push(body);
              this.push(null);
            }
          });
          stream.method = method;
          stream.url = url;
          stream.headers = headers;

          return stream;
        };
      };
    };
  };
};

exports.mockResponse = function() {
  return {
    body: "",
    headers: {},

    write: function(str) {
      this.body = this.body + str;
    },

    end: function() { },

    setHeader: function(header, val) {
      this.headers[header] = val;
    }
  };
};
