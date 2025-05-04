import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="image"
export default class extends Controller {
    static targets = ['input', 'preview', 'previewArea']

    preview() {
        const input = this.inputTarget;
        const images = this.previewTargets;
        const files = input.files;

        Array.from(files).forEach((file, _) => {
            // img & buttonを包むdiv要素を作成
            const newImageWrapper = document.createElement('div');
            newImageWrapper.dataset.imageTarget = 'wrapper';
            newImageWrapper.style.display = 'flex';
            newImageWrapper.style.flexDirection = 'column';
            newImageWrapper.style.alignItems = 'center';
            newImageWrapper.style.justifyContent = 'space-between';
            newImageWrapper.style.gap = '5px';

            // img要素を作成
            const newImage = document.createElement('img');
            newImage.style.width = '100px';
            newImage.dataset.imageTarget = 'preview';

            // button要素を作成
            const deleteButton = document.createElement('button');
            deleteButton.type = 'button';
            deleteButton.dataset.action = 'click->image#deleteImage';
            deleteButton.textContent = '削除';
            deleteButton.classList.add('mini', 'ui', 'basic', 'button');

            newImageWrapper.appendChild(newImage);
            newImageWrapper.appendChild(deleteButton);
            this.previewAreaTarget.appendChild(newImageWrapper);

            // 画像を読み込んで表示
            const reader = new FileReader();
            // set event handler which is called when file is loaded
            reader.onloadend = () => {
                newImage.src = reader.result;
            };
            // load file -> onloadend ↑ is triggered
            reader.readAsDataURL(file);
        });
    }

    deleteImage(event) {
        const button = event.currentTarget;
        const wrapper = button.closest('[data-image-target="wrapper"]');
        if (wrapper) {
            wrapper.remove();
        }
    }
}