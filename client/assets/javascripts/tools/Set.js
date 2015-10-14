function Set() {
    this.array = {};
}

Set.prototype.length = function () {
  return Object.keys(this.array).length;
};

Set.prototype.exists = function(key) {
    return (key in this.array);
};

Set.prototype.insert = function(key, value) {
    if (this.exists(key)) {
        console.log("Set::insert: "+key+" already exists.");
        return false;
    }

    if (value === undefined) {
        console.log("Set::insert: value is undefined for "+key+".");
        return false;
    }

    this.array[key] = value;
    return true;
};

Set.prototype.get = function(key) {
    if (!this.exists(key)) {
        return;
    }

    return this.array[key];
};

Set.prototype.unset = function(key) {
    if (this.exists(key))
        delete this.array[key];
};

Set.prototype.toJSON = function() {
    return this.array;
};