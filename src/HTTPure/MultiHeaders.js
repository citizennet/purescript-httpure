export const parseRawHeaders = f => headers => {
  const result = [];
  let key = null, value = null;

  for (const str of headers) {
    if (key === null) {
      key = str;
    } else if (value === null) {
      value = str;
    } else {
      result.push(f(key)(value));
      key = str;
      value = null;
    }
  }

  if (key !== null && value !== null) {
    result.push(f(key)(value));
  }

  return result;
};
