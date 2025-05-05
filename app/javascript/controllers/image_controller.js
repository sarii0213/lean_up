import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image"
export default class extends Controller {
    static targets = ['preview', 'previewArea']

    connect() {
        this.storedFiles = new DataTransfer();
    }

    preview(e) {
        const newFiles = e.currentTarget.files;
        // DataTransfer: ファイルをデータとして保持するオブジェクト
        const dataTransfer = this.#addFilesToDataTransfer(newFiles);
        this.#updateFileInput(e.currentTarget, dataTransfer);
        this.#createPreviews(newFiles);
    }

    deleteImage(e) {
        const wrapper = e.currentTarget.closest('[data-image-target="wrapper"]');
        wrapper ? wrapper.remove() : null;
    }

    #addFilesToDataTransfer(newFiles) {
        const dataTransfer = new DataTransfer();

        // 既にアップロードされたファイルを保持
        if (this.storedFiles.files.length > 0) {
            Array.from(this.storedFiles.files).forEach(file => {
                dataTransfer.items.add(file);
            });
        }

        // 新しいファイルを保持アイテムとして追加
        Array.from(newFiles).forEach(file => {
            dataTransfer.items.add(file);
        });
        return dataTransfer;
    }

    #updateFileInput(inputElement, dataTransfer) {
        inputElement.files = dataTransfer.files;
        this.storedFiles = dataTransfer;
    }

    #createPreviews(files) {
        Array.from(files).forEach(file => {
            const wrapper = this.#createImageWrapper();
            const image = this.#createImageElement();
            const deleteButton = this.#createDeleteButton();

            wrapper.appendChild(image);
            wrapper.appendChild(deleteButton);
            this.previewAreaTarget.appendChild(wrapper);

            this.#loadImagePreview(file, image);
        });
    }

    #createImageWrapper() {
        const wrapper = document.createElement('div');
        wrapper.dataset.imageTarget = 'wrapper';
        wrapper.style.display = 'flex';
        wrapper.style.flexDirection = 'column';
        wrapper.style.alignItems = 'center';
        wrapper.style.justifyContent = 'space-between';
        wrapper.style.gap = '5px';
        return wrapper;
    }

    #createImageElement() {
        const image = document.createElement('img');
        image.style.width = '100px';
        image.dataset.imageTarget = 'preview';
        return image;
    }

    #createDeleteButton() {
        const button = document.createElement('button');
        button.type = 'button';
        button.dataset.action = 'click->image#deleteImage';
        button.textContent = '削除';
        button.classList.add('mini', 'ui', 'basic', 'button');
        return button;
    }

    #loadImagePreview(file, imageElement) {
        const reader = new FileReader();
        reader.onloadend = () => {
            imageElement.src = reader.result;
        };
        reader.readAsDataURL(file);
    }
}
