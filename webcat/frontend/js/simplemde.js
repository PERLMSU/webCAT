import SimpleMDE from "simplemde";

customElements.define('markdown-editor', class extends HTMLElement {
    constructor() {
        super();
        this._content = "";
    }

    get content() {
        return this._content;
    }

    set content(val) {
        if (this._content == val) return;
        this._content = val;
        if (!this._mde) return;
        this._mde.value(val);
    }

    connectedCallback() {
        let element = document.createElement('textarea');
        this.appendChild(element);
        this._mde = new SimpleMDE({element: element, initialValue: this._content});
        this._mde.codemirror.on("change", () => {
	          this._content = this._mde.value();
            this.dispatchEvent(new CustomEvent("contentChanged"));
        });
    }
});
