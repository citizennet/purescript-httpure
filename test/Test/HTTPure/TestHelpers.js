import { Readable } from "stream";

export const mockRequestImpl = httpVersion => method => url => body => headers => () => {
    const stream = new Readable({
        read: function (size) {
            this.push(body);
            this.push(null);
        }
    });
    stream.method = method;
    stream.url = url;
    stream.headers = Object.fromEntries(Object.entries(headers).map(([key, values]) => [key, values[values.length - 1]]));
    stream.headersDistinct = headers;
    stream.httpVersion = httpVersion;

    return stream;
};

export const mockResponse = () => ({
    body: "",
    headers: {},

    write: function (str, encoding, callback) {
        this.body = this.body + str;
        if (callback) {
            callback();
        }
    },

    end: function (str, encoding, callback) {
        if (callback) {
            callback();
        }
    },

    on: function () {},
    once: function () {},
    emit: function () {},

    setHeader: function (header, val) {
        this.headers[header] = val;
    },
});

export const stringToStream = str => {
    const stream = new Readable();
    stream._read = function () {};
    stream.push(str);
    stream.push(null);
    return stream;
}
