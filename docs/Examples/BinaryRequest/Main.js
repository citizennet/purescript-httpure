import crypto from 'crypto';

export function sha256sum(buffer) {
  return crypto.createHash('sha256').update(buffer).digest('hex');
}
