"use strict";

exports.encodeURIComponent = encodeURIComponent

exports.decodeURIComponentImpl = function(s) {
  try {
    return decodeURIComponent(s);
  } catch(error) {
    return null;
  }
};
