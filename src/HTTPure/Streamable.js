"use strict";

function createStreamFrom (data) {
  var stream = new require('stream').Readable();
  stream._read = function () {};
  stream.push(data);
  stream.push(null);
  return stream;
}

exports.createStreamFromString = function (str) {
  return createStreamFrom(str);
}

exports.createStreamFromBuffer = function (buf) {
  return createStreamFrom(buf);
}
