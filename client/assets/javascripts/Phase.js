/**
 * Phase store the phases and operations we want to realise during the different parts game
 * @param name      Is the name of the phase
 * @param before    Method to process at the first beginning, when the connection is ready to be reached
 * @param starting  Method to process when the phase will begin
 * @param ending    Method to process when an other will begin (only one phase should be running at same time)
 * @constructor
 */
function Phase(name, before, starting, ending) {

    var States = {UNDEFINED:"undefined", INITIALIZED:"initialized", STARTED:"started", ENDED:"ended"};

    this.name = name;
    this.before = before;
    this.starting = starting;
    this.ending = ending;

    /**
     * Current state of the phase
     * @type {string}
     */
    this.state = States.UNDEFINED;

    /**
     * Store operations that can be processed during starting phase
     * @type {{}}
     */
    this.operations = {};

    /**
     * Returns if the asked phase is that one
     * @type {function(this:Phase)}
     */
    this.is = function(name) {
        return (name == this.name);
    }.bind(this);

    /**
     * Initialize the described phase
     * @type {function(this:Phase)}
     * @return boolean if the phase has been initialized or not
     */
    this.init = function(params) {
        if (this.state != States.UNDEFINED) {
            console.log('Phase-'+this.name+'::init: State must be UNDEFINED ('+this.state+')');
            return false;
        }

        this.before(params);

        this.state = States.INITIALIZED;
        return true;
    }.bind(this);

    /**
     * Process the start method
     * @type {function(this:Phase)}
     * @return boolean
     */
    this.start = function(params) {
        if (this.state != States.INITIALIZED) {
            console.log('Phase-'+this.name+'::start: State must be INITIALIZED ('+this.state+')');
            return false;
        }

        this.starting(params);

        this.state = States.STARTED;
        return true;
    }.bind(this);

    /**
     * Process the end method
     * @type {function(this:Phase)}
     * @return boolean
     */
    this.end = function(params) {
        if (this.state != States.STARTED) {
            console.log('Phase-'+this.name+'::start: State must be STARTED ('+this.state+')');
            return false;
        }

        this.ending(params);

        this.state = States.ENDED;
        return true;
    }.bind(this);

    /**
     * Returns if the operation is registered
     * @type {function(this:Phase)}
     */
    this.hasOperation = function(name) {
        return (this.operations[name] !== undefined);
    }.bind(this);

    /**
     * Returns if the phase is started (condition to run operations).
     * @returns {boolean}
     */
    this.isStarted = function() {
        return (this.state == States.STARTED);
    }.bind(this);

    /**
     * Add an operation that can be runned when the phase is started
     * @type {function(this:Phase)}
     */
    this.addOperation = function(name, operation) {
        if (this.hasOperation(name)) {
            console.log('Phase::addOperation: '+name+' can\'t be declared twice.');
            return false;
        }

        this.operations[name] = operation;

        return true;
    }.bind(this);

    /**
     * Execute a method, before, checks if phase is started & method exists
     * @type {function(this:Phase)}
     * @return false or method return.
     */
    this.run = function(opName) {
        if (this.state != States.STARTED) {
            console.log('Phase::run: '+opName+' can\'t be processed because state is '+this.state+' (expected: '+States.STARTED+').');
            return false;
        }

        if (this.operations['name'] !== undefined) {
            console.log('Phase::run: '+opName+' doesn\'t exist.');
            return false;
        }

        return this.operations[opName];
    }.bind(this);

    /**
     * Give a readable name and state of the phase
     * @type {function(this:Phase)}
     * @return String
     */
    this.print = function() {
        return "Phase "+this.name+" is "+this.state;
    }.bind(this);
}
