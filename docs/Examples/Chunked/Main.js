"use strict";

exports.stagger = function (start) {
  return function (end) {
    return function (delay) {
      var stream = new require('stream').Readable();
      stream._read = function () {};
      stream.push(start);
      setTimeout(function () {
        stream.push(end);
        stream.push(null);
      }, delay);
      return stream;
    };
  };
};
