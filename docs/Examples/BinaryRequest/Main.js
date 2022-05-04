import crypto from 'crypto';

export const sha256sum = buffer =>
    crypto.createHash('sha256').update(buffer).digest('hex');
