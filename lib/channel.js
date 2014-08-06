var Channel, EventEmitter,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

EventEmitter = require('events').EventEmitter;

Channel = (function(_super) {
  __extends(Channel, _super);

  function Channel(channelId, process) {
    var handler;
    this.process = process;
    this.channelId = channelId.toString();
    handler = (function(_this) {
      return function(json) {
        var data, id, type, _ref;
        _ref = JSON.parse(json), type = _ref.type, data = _ref.data, id = _ref.id;
        if (_this.channelId === id) {
          return _this.emit(type, data);
        }
      };
    })(this);
    this.process.on('message', handler);
  }

  Channel.prototype.send = function(type, data) {
    return this.process.send(JSON.stringify({
      type: type,
      data: data,
      id: this.channelId
    }));
  };

  return Channel;

})(EventEmitter);

module.exports = {
  Channel: Channel
};
