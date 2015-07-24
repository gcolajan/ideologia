function Effects(abs, rel) {
    this.abs = abs;
    this.rel = rel;

    this.apply = function(gaugesSet) {
        for (var id = 1 ; id <= 3 ; id++)
            gaugesSet.get(id).applyEffect(this.rel[id], this.abs[id]);
    }
}