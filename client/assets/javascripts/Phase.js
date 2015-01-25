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
     * They are called when the server send something (except phases)
     * @type {{}}
     */
    this.operations = new Set();

    /**
     * Store functions to react when the user trigger something from the UI
     * @type {{}}
     */
    this.userActions = new Set();

    /**
     * Tell if this phase run on the popunder
     * @type {boolean}
     */
    this.hasPopunder = false;

    /**
     * Returns if the asked phase is that one
     * @type {function(this:Phase)}
     */
    this.is = function(name) {
        return (name == this.name);
    }.bind(this);

    /**
     * Returns if the phase is started (condition to run operations).
     * @returns {boolean}
     */
    this.isStarted = function() {
        return (this.state == States.STARTED);
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
     * Execute a method, before, checks if phase is started & method exists
     * @type {function(this:Phase)}
     * @return false or method return.
     */
    this.getOperation = function(opName) {
        if (!this.isStarted()) {
            console.log('Phase::getOperation: '+opName+' can\'t be processed because state is '+this.state+' (expected: '+States.STARTED+').');
            return undefined;
        }

        return this.operations.get(opName);
    }.bind(this);

    /**
     * Execute a method, before, checks if phase is started & method exists
     * @type {function(this:Phase)}
     * @return false or method return.
     */
    this.getUserAction = function(uaName) {
        if (!this.isStarted()) {
            console.log('Phase::getUserAction: '+uaName+' can\'t be processed because state is '+this.state+' (expected: '+States.STARTED+').');
            return undefined;
        }

        return this.userActions.get(uaName);
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
