"use strict";

exports.mockRequestImpl = function(httpVersion) {
  return function(method) {
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
            stream.httpVersion = httpVersion;

            return stream;
          };
        };
      };
    };
  };
};

exports.mockResponse = function() {
  return {
    body: "",
    headers: {},

    write: function(str, encoding, callback) {
      this.body = this.body + str;
      if (callback) {
        callback();
      }
    },

    end: function(str, encoding, callback) {
      if (callback) {
        callback();
      }
    },

    on: function() { },
    once: function() { },
    emit: function() { },

    setHeader: function(header, val) {
      this.headers[header] = val;
    }
  };
};

exports.stringToStream = function (str) {
  var stream = new require('stream').Readable();
  stream._read = function () {};
  stream.push(str);
  stream.push(null);
  return stream;
}
