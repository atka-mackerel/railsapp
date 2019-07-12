const TAG_VIEW_MODE_VIEW = 1;
const TAG_VIEW_MODE_EDIT = 2;

function viewMemoDetail(id) {
  window.location = `/memos/${id}`
}

// document.addEventListener('turbolinks:load', () => {
document.addEventListener('DOMContentLoaded', () => {
  // 検索フォームのイベント設定
  // let memoSearchForm = document.getElementById('memo-search-form');
  // if (memoSearchForm) {
  //   memoSearchForm.addEventListener('ajax:success', (response) => {
  //     let memoResult = document.getElementById('memo-result');
  //     memoResult.innerHTML = response.detail[2].response;
  //   });
  // }

  // タグ検索リンクのイベント設定
  // let tagSearchLinks = document.querySelectorAll('.tag-search-link');
  // tagSearchLinks.forEach(link => {
  //   link.addEventListener('ajax:success', (response) => {
  //     console.log(response.detail[2].response);
  //     document.write(response.detail[2].response);
  //   });
  // });

  // let delMemoBtns = document.querySelectorAll('.del-memo-btn');
  // delMemoBtns && delMemoBtns.forEach(btn => btn.addEventListener('click', (e) => e.stopPropagation() ) );

  let canvas = document.getElementById('draw-area');
  if (!canvas) {
    return;
  }
  
  let ctx;
  let Xpoint;
  let Ypoint;
  let moveflg = 0;

  //初期値（サイズ、色、アルファ値）の決定
  let defSize = 2;
  let defColor = "#555";

  const context = () => {
    ctx = ctx || document.getElementById('draw-area').getContext('2d');
    return ctx;
  }

  setTimeout(scrollTo, 100, 0, 1);

  const adjustCanvasSize = () => {
    drawContainer = document.querySelector('.draw-container');
    canvas.width = drawContainer.offsetWidth;
    canvas.height = drawContainer.offsetHeight;
  }

  const startPoint = (e) => {
    e.preventDefault();
    context().beginPath();
    setPoint(e);
    context().moveTo(Xpoint, Ypoint);
  }

  const setPoint = (e) => {
      let pos = getPosT(e);
      Xpoint = pos.x;
      Ypoint = pos.y;
  }

  const movePoint = (e) => {
    if (e.buttons === 1 || e.witch === 1 || e.type == 'touchmove') {
      let rect = e.target.getBoundingClientRect();
      moveflg = 1;
      setPoint(e);

      let _ctx = context();
      _ctx.lineTo(Xpoint, Ypoint);
      _ctx.lineCap = "round";
      _ctx.lineWidth = defSize * 2;
      _ctx.strokeStyle = defColor;
      _ctx.stroke();
    }
  }

  const endPoint = (e) => {
    if (moveflg === 0) {
      let _ctx = context();
      _ctx.lineTo(Xpoint - 1, Ypoint - 1);
      _ctx.lineCap = "round";
      _ctx.lineWidth = defSize * 2;
      _ctx.strokeStyle = defColor;
      _ctx.stroke();
    }
    moveflg = 0;
  }

  // タップ位置を取得する為の関数群
  function scrollX(){return document.documentElement.scrollLeft || document.body.scrollLeft;}
  function scrollY(){return document.documentElement.scrollTop || document.body.scrollTop;}
  function getPosT (event) {
    let mouseX, mouseY;
    if (event.touches) {
      mouseX = event.touches[0].clientX - $(canvas).offset().left;
      mouseY = event.touches[0].clientY - $(canvas).offset().top + $(window).scrollTop();
    } else {
      mouseX = event.layerX - 15;
      mouseY = event.layerY - 15 + $(window).scrollTop();
    }
    return {x:mouseX, y:mouseY};
  }

  const saveDataUrl = () => {
    let dataUrl = canvas.toDataURL();
    console.log(dataUrl);
    document.getElementById('hidden-content').value = dataUrl;
  }

  const onModalShown = (e) => {
    adjustCanvasSize();
    initCanvas();
  }

  const viewImage = () => {
    document.getElementById('draw-view').src = document.getElementById('hidden-content').value;
  }

  const onClickDrawComplete = (e) => {
    saveDataUrl();
    viewImage();
    $('#drawModal').modal('hide');
  }

  const onModalHidden = (e) => {
    context().clearRect(0, 0, canvas.width, canvas.height);
  }

  // キャンバスサイズ調整
  // adjustCanvasSize();

  // dataurlからイメージを生成しキャンバスに描画
  const initCanvas = () => {
    let canvasImg = new Image;
    canvasImg.addEventListener('load', () => {
      console.log('canvasImg', canvasImg);
      context().drawImage(canvasImg, 0, 0);
    });
    canvasImg.src = document.getElementById('hidden-content').value;
  }

  // キャンバスのクリア
  const clearCanvas = () => {
    document.getElementById('hidden-content').value = '';
  }

  // イメージのクリア
  const clearDrawView = () => {
    document.getElementById('draw-view').src = '';
  }

  const onClearViewClick = () => {
    clearDrawView();
    clearCanvas();
  }

  const removeTag = (event) => {
    console.log(event);
    let tagName = event.target.parentNode.getAttribute('tag-name');
    let viewTagGroup = document.querySelector(`.view-tag-group[tag-name='${tagName}']`);
    let editTagGroup = document.querySelector(`.edit-tag-group[tag-name='${tagName}']`);

    viewTagGroup.parentNode.removeChild(viewTagGroup);
    editTagGroup.parentNode.removeChild(editTagGroup);
  }

  const addTag = (event) => {
    let name;
    txtAddTag = document.getElementById('txt-add-tag');
    if (!(name = txtAddTag.value) || document.querySelector(`[tag-name='${name}']`)) {
      txtAddTag.value = '';
      return;
    }

    let viewTagGroup = createElement('div', { class: 'view-tag-group float-left', 'tag-name': name });
    let viewTagLink = createBadgeLinkElement(name);
    let hiddenTag = createElement('input', { type: 'hidden', name: 'tags[][name]', value: name });
    viewTagGroup.appendChild(viewTagLink);
    viewTagGroup.appendChild(hiddenTag);
    document.querySelector('.view-mode').appendChild(viewTagGroup);

    let editTagGroup = createElement('div', { class: 'edit-tag-group float-left', 'tag-name': name });
    let editTagLink = createBadgeLinkElement(name);
    let removeLink = createElement('a', { class: 'link-remove-tag', 'tag-name': name });
    let removeIcon = createElement('i', { class: 'fa fa-times-circle mr-2 text-danger' });
    removeLink.addEventListener('click', removeTag);
    removeLink.appendChild(removeIcon);
    editTagGroup.appendChild(editTagLink);
    editTagGroup.appendChild(removeLink);
    document.querySelector('.edit-tag-group-container').appendChild(editTagGroup);

    txtAddTag.value = '';
  }

  const createElement = (tagName, attributes = {}) => {
    let elem = document.createElement(tagName);
    for (key in attributes) {
      if (elem[key] !== undefined) {
        elem[key] = attributes[key];
      } else {
        elem.setAttribute(key, attributes[key]);
      }
    }
    return elem;
  }

  const createBadgeLinkElement = (text) => {
    let attributes = {
      class: 'badge badge-secondary mr-1',
      innerText: text,
    };

    return createElement('span', attributes);
  }

  const switchTagViewMode = (mode) => {
    viewModeContainer = document.querySelector('.view-mode');
    editModeContainer = document.querySelector('.edit-mode');
    switch (mode) {
      case TAG_VIEW_MODE_VIEW:
        viewModeContainer.classList.remove('d-none');
        editModeContainer.classList.add('d-none');
        break;
      case TAG_VIEW_MODE_EDIT:
        viewModeContainer.classList.add('d-none');
        editModeContainer.classList.remove('d-none');
        break;
      default:
        viewModeContainer.classList.add('d-none');
        editModeContainer.classList.add('d-none');
    }
  }

  const onClickEditTag = (event) => {
    event.preventDefault();
    switchTagViewMode(TAG_VIEW_MODE_EDIT);
  }

  const onClickCompleteTag = (event) => {
    event.preventDefault();
    switchTagViewMode(TAG_VIEW_MODE_VIEW);
  }

  // const addEventListenerForDestroyTagLink = (event) => {
  //   console.log('addEvent');
  //   event.target.addEventListener('ajax:success', replaceTagsContainer);
  // }

  // const onSuccessDestroyTag = (e) => {
  //   console.log(e.detail[0].body.innerHTML);
  //   tagsContainer.innerHTML = e.detail[0].body.innerHTML;
  // }

  const stopDefault = (event) => {
    // if (event.touches[0].target.tagName.toLowerCase() == "li") { return; }
    // if (event.touches[0].target.tagName.toLowerCase() == "input") { return; }

    event.preventDefault();
  }

  // タッチイベントの初期化
  canvas.addEventListener("touchstart", stopDefault, false);
  canvas.addEventListener("touchmove", stopDefault, false);
  canvas.addEventListener("touchend", stopDefault, false); 
  // ジェスチャーイベントの初期化
  canvas.addEventListener("gesturestart", stopDefault, false);
  canvas.addEventListener("gesturechange", stopDefault, false);
  canvas.addEventListener("gestureend", stopDefault, false); 
  // PC対応
  canvas.addEventListener('mousedown', startPoint, false);
  canvas.addEventListener('mousemove', movePoint, false);
  canvas.addEventListener('mouseup', endPoint, false);
  // スマホ対応
  canvas.addEventListener('touchstart', startPoint, false);
  canvas.addEventListener('touchmove', movePoint, false);
  canvas.addEventListener('touchend', endPoint, false);

  // 手書き完了時
  document.getElementById('btn-draw-complete').addEventListener('click', onClickDrawComplete);

  // イメージクリア時
  document.getElementById('btn-draw-clear').addEventListener('click', onClearViewClick);

  // モーダル起動時
  $('#drawModal').on('shown.bs.modal', onModalShown);

  // モーダル終了時
  $('#drawModal').on('hidden.bs.modal', onModalHidden);

  // タグ削除時
  document.querySelectorAll('.link-remove-tag').forEach(link => {
    link.addEventListener('click', removeTag);
  });

  document.getElementById('btn-add-tag').addEventListener('click', addTag);
  document.getElementById('btn-edit-tag').addEventListener('click', onClickEditTag);
  document.getElementById('btn-complete-tag').addEventListener('click', onClickCompleteTag);
  document.getElementById('add-tag-form').addEventListener('submit', (event) => {
    event.preventDefault();
    addTag();
  });

  switchTagViewMode(TAG_VIEW_MODE_VIEW);

}, false);
