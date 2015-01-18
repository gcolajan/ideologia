function Collection() {
	this.length = 0;
	this.list = [];
}

Collection.prototype.push = function(element) {
	if (element === undefined || this.exists(element))
		return false;

	this.length++;

	// Return the new number of elements.
	return this.list.push(element);
};

Collection.prototype.pop = function() {
	if (this.length() == 0)
		return undefined;

	this.length--;
	return this.list.pop();
}

Collection.prototype.peek = function() {
	if (this.length() == 0)
		return undefined;

	return this.list[this.length-1];
}

Collection.prototype.shift = function() {
	if (this.length() == 0)
		return undefined;

	this.length--;
	return this.list.shift();
}

Collection.prototype.indexOf = function(element) {
	return this.list.indexOf(element);
}

Collection.prototype.exists = function(element) {
	return (this.indexOf(element) > -1);
};

Collection.prototype.get = function(needle, field) {
	if (field === undefined) // if field is null, needle is an index
		return this.list[needle];
	else
		for (var i = 0 ; i < this.length ; i++)
			if (this.list[i][field] == needle)
				return this.list[i];
	return null;
};

Collection.prototype.getCollectionOf = function(field) {
	var collection = new Collection;
	this.forEach(function(element) {
		if (element[field] !== undefined)
			collection.push(element[field]);
	});
	return collection;
};

Collection.prototype.concat = function(other) {
	this.list = this.list.concat(other.list);
	this.length += other.length;
};

Collection.prototype.unset = function(element) {
	var index = this.indexOf(element);
	if (index > -1) {
		this.list.splice(index, 1);
		this.length--;
		return true;
	}
	return false;
};

Collection.prototype.forEach = function(fun /*, thisp*/) {
	var len = this.length >>> 0;
	if (typeof fun != "function") {
		throw new TypeError();
	}

	var thisp = arguments[1];
	for (var i = 0; i < len; i++) {
		if (i in this.list) {
			fun.call(thisp, this.list[i], i, this.list);
		}
	}
};

Collection.prototype.toJSON = function() {
	return this.list;
}
