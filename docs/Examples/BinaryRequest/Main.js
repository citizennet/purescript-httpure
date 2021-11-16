'use strict';

const crypto = require('crypto');

exports.sha256sum = function(buffer) {
  return crypto.createHash('sha256').update(buffer).digest('hex');
}
