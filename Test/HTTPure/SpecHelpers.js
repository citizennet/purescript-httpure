"use strict";

exports.mockResponse = function() {
    return {
        body: "",
        headers: {},

        write: function(str) {
            this.body = this.body + str;
        },

        end: function() {
        },

        setHeader: function(header, val) {
            this.headers[header] = val;
        }
    };
};
