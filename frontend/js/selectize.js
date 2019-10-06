import $ from 'jquery';
import 'selectize/dist/js/standalone/selectize.min.js';

customElements.define('selectize-multi', class extends HTMLElement {
    constructor() {
        super();
        this._options = [];
        this._items = [];
    }

    get selected() {
        return this._items;
    }

    set selected(items) {
        if(items === this._items) return;
        this._items = items;
        if (!this._selectize) return;
        this._selectize.setValue(this._items);
    }

    set options(data) {
        this._options = data;
        if (!this._selectize) return;
        this._selectize.clearOptions();
        this._selectize.addOption(this._options.map((val) => ({value: val, text: val})));
    }

    connectedCallback() {
        let element = document.createElement("select");
        element.setAttribute("multiple", true);
        this.appendChild(element);
        let $select = $(element).selectize({
            options: this._options.map((val) => ({value: val, text: val})),
            items: this._items,
            onChange: (value) => {
                this._items = value;
                this.dispatchEvent(new CustomEvent("selectionChanged"));
            },
        });

        this._selectize = $select[0].selectize;
    }
});
