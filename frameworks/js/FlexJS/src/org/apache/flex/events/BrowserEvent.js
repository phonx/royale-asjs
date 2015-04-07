/**
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
goog.provide('org_apache_flex_events_BrowserEvent');

goog.require('goog.events.BrowserEvent');
//goog.require('org_apache_flex_events_Event');



/**
 * @constructor
 * @extends {org_apache_flex_events_Event}
 */
org_apache_flex_events_BrowserEvent = function() {
//  org_apache_flex_events_BrowserEvent.base(this, 'constructor');

};
//goog.inherits(org_apache_flex_events_BrowserEvent,
//    org_apache_flex_events_Event);


/**
 * Metadata
 *
 * @type {Object.<string, Array.<Object>>}
 */
org_apache_flex_events_BrowserEvent.prototype.FLEXJS_CLASS_INFO =
    { names: [{ name: 'BrowserEvent',
                qName: 'org_apache_flex_events_BrowserEvent' }] };


/**
 * @type {?goog.events.BrowserEvent}
 */
org_apache_flex_events_BrowserEvent.prototype.wrappedEvent = null;


/**
 */
org_apache_flex_events_BrowserEvent.prototype.preventDefault = function() {
  this.wrappedEvent.preventDefault();
}

Object.defineProperties(org_apache_flex_events_BrowserEvent.prototype, {
    /** @expose */
    currentTarget: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			var o = this.wrappedEvent.currentTarget;
			if (o && o.flexjs_wrapper)
			  return o.flexjs_wrapper;
			return o;
		}
	},
    /** @expose */
	button: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			return this.wrappedEvent.button;
		}
	},
    /** @expose */
	charCode: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			return this.wrappedEvent.charCode;
		}
	},
    /** @expose */
	clientX: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			return this.wrappedEvent.clientX;
		}
	},
    /** @expose */
	clientY: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			return this.wrappedEvent.clientY;
		}
	},
    /** @expose */
	keyCode: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			return this.wrappedEvent.keyCode;
		}
	},
    /** @expose */
	offsetX: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			return this.wrappedEvent.offsetX;
		}
	},
    /** @expose */
	offsetY: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			return this.wrappedEvent.offsetY;
		}
	},
    /** @expose */
	screenX: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			return this.wrappedEvent.screenX;
		}
	},
    /** @expose */
	screenY: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			return this.wrappedEvent.screenY;
		}
	},
    /** @expose */
	relatedTarget: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			var o = this.wrappedEvent.relatedTarget;
			if (o && o.flexjs_wrapper)
			  return o.flexjs_wrapper;
			return o;
		}
	},
    /** @expose */
    target: {
		/** @this {org_apache_flex_events_BrowserEvent} */
		get: function() {
			var o = this.wrappedEvent.target;
			if (o && o.flexjs_wrapper)
			  return o.flexjs_wrapper;
			return o;
		}
	}
});


