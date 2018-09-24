/* global exports */

"use strict";

exports.aggregateChunks = function (stream) {
  return function(onEnd) {
    return function() {
      var chunks = [];
      stream.on("data", function (chunk) {
        chunks.push(chunk);
      });
      stream.on("end", function() {
        onEnd(chunks)();
      });
    };
  }
};
