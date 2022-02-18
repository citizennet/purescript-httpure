"use strict";
import * as ztream from 'stream'

export function mockRequestImpl(httpVersion) {
  return function(method) {
    return function(url) {
      return function(body) {
        return function(headers) {
          return function() {
            var stream = new ztream.Readable({
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
}

export function mockResponse() {
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
}

export function stringToStream(str) {
  var stream = new ztream.Readable();
  stream._read = function () {};
  stream.push(str);
  stream.push(null);
  return stream;
}
