// TODO
// reduxでステート管理する
// ファイル分割する

import React, { Component } from 'react';
import ReactDOM from 'react-dom';

const filterComments = (content, filterText) => {
    let hasFilteredComment = false;
    let commentsCount = 0;
    if (content.comments) {
        commentsCount += content.comments.items.length;
        content.comments.items = content.comments.items.map(comment => {
            let hasFilteredReply = false;
            if (comment.replies) {
                commentsCount += comment.replies.items.length;
                comment.replies.items = comment.replies.items.map(reply => {
                    if (!filterText) {
                        reply.hide = false;
                        return reply;
                    }
                    let includesText = reply.text.includes(filterText);
                    hasFilteredReply = hasFilteredReply || includesText;
                    reply.hide = !includesText;
                    return reply;
                });
            }
            if (!filterText) {
                comment.hide = false;
                return comment;
            }
            comment.hide = !(comment.text.includes(filterText) || hasFilteredReply);
            hasFilteredComment = hasFilteredComment || !comment.hide
            return comment;
        });
    }
    content.commentsCount = commentsCount;
    if (!filterText) {
        content.hide = false;
        return content;
    }
    content.hide = !hasFilteredComment;
    return content;
}

const filterContents = (contents, filterText) => {
    return contents.map(content => filterComments(content, filterText));
}

const formToJson = (form) => {
    return Array.prototype.reduce.call(
        form.querySelectorAll(`input:not([type='checkbox']),input[type='checkbox']:checked`), 
        (o, el) => (o[el.name] = el.value, o), {});
}

const jsonToQueryString = (json) => {
    return Object.keys(json)
        .map((key) => `${key}=${encodeURIComponent(json[key])}`)
        .join('&');
}

const formToQueryString = (form) => {
    let json = formToJson(form);
    return jsonToQueryString(json);
}

class MediaList extends Component {
    constructor(props) {
        super(props);
        this.props.references['MediaList'] = this;
        this.addResults = this.addResults.bind(this);
        this.state = {
            nextPageToken: props.result.nextPageToken,
            pageInfo: props.result.pageInfo,
            contents: filterContents(props.result.items, ''),
            viewMoreDataLink: props.result.nextPageToken ? true : false,
            loading: false,
            filterText: '',
            isOnSubmit: true,
        };
    }

    render() {
        return (
            <div className="card shadow mb-4">
                <div className="card-header clear-fix">
                    <span className="my-auto">検索結果&nbsp;{this.state.pageInfo.totalResults}&nbsp;件中&nbsp;{this.state.contents.length}件</span>
                    <div className="form-inline float-right">
                        <button className="btn btn-secondary btn-sm mr-2" onClick={this.handleCommentFilterChange.bind(this)}>コメントフィルタ</button>
                        <input type="text" id="filterText" className="form-control" />
                    </div>
                </div>
                {this.state.contents.length > 0
                    ? <div className="card-body">
                        <ul className="list-unstyled">
                            {this.state.contents.map((content, i) => {
                                return <MediaContent key={i} id={i} content={content} isOnSubmit={this.state.isOnSubmit} />
                            })}
                        </ul>
                        {this.state.viewMoreDataLink
                            ? <button className="btn btn-link" onClick={this.handleSubmit}>更に表示</button>
                            : false
                        }
                        {this.state.loading
                            ? <div className="spinner-border text-primary" role="status">
                                <span className="sr-only">Loading...</span>
                              </div>
                            : false
                        }
                      </div>
                    : false
                }
            </div>
        )
    }

    addResults = (result, isOnSubmit) => {
        this.setState({
            nextPageToken: result.nextPageToken,
            pageInfo: result.pageInfo,
            contents: filterContents(isOnSubmit ? result.items : this.state.contents.concat(result.items)),
            viewMoreDataLink: result.nextPageToken ? true : false,
            isOnSubmit: isOnSubmit,
        });
    }

    handleCommentFilterChange = (e) => {
        let filterText = document.getElementById('filterText').value;
        this.setState({
            contents: filterContents(this.state.contents, filterText),
            filterText: filterText,
            isOnSubmit: false,
        });
    }

    handleSubmit = () => {
        let viewMoreDataLink = this.state.viewMoreDataLink;
        this.setState({
            viewMoreDataLink: false,
            loading: true,
        });
        const headers = {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'
        };
        fetch(`/ytsearch/search?page_token=${encodeURIComponent(this.state.nextPageToken)}`, { headers })
            .then((res) => res.json())
            .then(result => {
                this.addResults(result);
            })
            .catch((error) => {
                console.error(error);
                // TODO エラー処理
            })
            .finally(() => {
                this.setState({
                    viewMoreDataLink: viewMoreDataLink,
                    loading: false,
                });
            });
    }
}

const MediaComments = ({ comments }) => {
    return (
        <ul className="list-unstyled">
            {comments.items.map((comment, key) => {
                return (
                    <li key={key} className={"media media-comment" + (comment.hide ? ' d-none' : '')}>
                        <a href="#" className="mr-1">
                            <img src={comment.profileImageUrl} alt="メディアの画像" />
                        </a>
                        <div className="media-body">
                            <h6 className="mt-0 text-break">{comment.author}</h6>
                            <p className="text-break">{comment.text}</p>
                            {comment.replies ?
                                <MediaComments comments={comment.replies} parent={this} /> :
                                false
                            }
                        </div>
                    </li>
                )
            })}
        </ul>
    )
}

class MediaContent extends Component { 
    static get NEXT_BTN_TEXT() {
        return {
            'collapse': 'コメントを閉じる',
            '': 'コメントを表示',
        }
    }

    constructor(props){
        console.log('MediaContent');
        super(props);
        this.initialState = this.initialState.bind(this);
        this.state = this.initialState(props);
    }

    initialState = (props) => {
        let nextPageToken = props.content.comments ? props.content.comments.nextPageToken : '';
        let newState = props.isOnSubmit || !this.state
            ? {
                id: props.id,
                content: props.content,
                btnText: MediaContent.NEXT_BTN_TEXT[''],
                collapsed: 'collapse',
                viewMoreDataLink: nextPageToken ? true : false,
                loading: false,
            }
            : {
                content: props.content,
            };
        this.isOnSubmit = false;
        return newState;
    }

    componentWillReceiveProps(nextProps) {
        this.setState(this.initialState(nextProps));
    }

    handleCommentBtnClick = (e) => {
        this.setState({
            collapsed: this.state.collapsed ? '' : 'collapse',
            btnText: MediaContent.NEXT_BTN_TEXT[this.state.collapsed],
        });

        if (this.state.collapsed) {
            const nav = document.querySelector('.navbar');
            $("html,body").animate({scrollTop:$(e.target).offset().top - nav.clientHeight - 40}, 500);
        }
    }

    handleSubmit = () => {
        let viewMoreDataLink = this.state.viewMoreDataLink;
        this.setState({
            viewMoreDataLink: false,
            loading: true,
        });
        const headers = {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8'
        };
        const params = {
            video_id: this.state.content.videoId,
            page_token: this.state.content.comments.nextPageToken,
        };
        fetch(`/ytsearch/comments?${jsonToQueryString(params)}`, { headers })
            .then((res) => res.json())
            .then(result => {
                let comments = this.state.content.comments;
                comments.nextPageToken = result.nextPageToken;
                comments.items = comments.items.concat(result.items);
                let newContent = filterComments(this.state.content, document.getElementById('filterText').value);
                this.setState({
                    content: newContent,
                });
            })
            .catch((error) => {
                console.error(error);
                // TODO エラー処理
            })
            .finally(() => {
                this.setState({
                    viewMoreDataLink: viewMoreDataLink,
                    loading: false,
                });
            });
    }

    render() {
        return (
            this.state.content.hide ?
                false :
                <li className="media mb-3 media-movies">
                    <div className="mr-3">
                        <img src={this.state.content.thumbnail.url} alt="メディアの画像" />
                    </div>
                    <div className="media-body clearfix">
                        <a href={`https://www.youtube.com/watch?v=${encodeURIComponent(this.state.content.videoId)}`} target="_blank" >
                            <h5 className="mt-0 text-break">{this.state.content.title}</h5>
                        </a>
                        <p className="text-break">{this.state.content.description}</p>
                        <small className="text-muted float-right">{this.state.content.publishedAt}</small>
                        {this.state.content.comments && this.state.content.comments.items.length > 0 ?
                            <div>
                                <button className="btn btn-outline-secondary btn-sm" data-toggle="collapse"
                                    data-target={'#collapseComment' + this.state.id} aria-expanded="false"
                                    aria-controls={'collapseComment' + this.state.id}
                                    onClick={this.handleCommentBtnClick}>
                                    {this.state.btnText}
                                </button>
                                <span className="ml-3">
                                    {this.state.content.comments.commentCount}&nbsp;件中&nbsp;{this.state.content.commentsCount}件
                                </span>
                                <div className={this.state.collapsed} id={'collapseComment' + this.state.id}>
                                    <div className="card card-body comments">
                                        <MediaComments comments={this.state.content.comments} />
                                        <div>
                                            {this.state.viewMoreDataLink ?
                                                <button className="btn btn-link" onClick={this.handleSubmit}>更に表示</button> :
                                                false
                                            }
                                            {this.state.loading ?
                                                <div className="spinner-border text-primary" role="status">
                                                    <span className="sr-only">Loading...</span>
                                                </div> :
                                                false
                                            }
                                        </div>
                                    </div>
                                </div>
                            </div> :
                            false
                        }
                    </div>
                </li>
        )
    }
}

class AlertMessage extends Component {
    constructor(props) {
        super(props);
        this.props.references['AlertMessage'] = this;
        this.state = {
            message: this.props.errors.join("\n"),
            type: this.props.type,
        };
    }

    closeMessage = () => {
        this.setState({
            message: null,
        });
    }

    showMessage = (errors, type) => {
        this.setState({
            message: errors.join("\n"),
            type: type,
        });
    }

    render() {
        return (this.state.message
            ? <div style={{ whiteSpace: 'pre-line' }} className={"fixed-top alert alert-dismissible fade show alert-" + this.state.type} role="alert">
                <button type="button" className="close" aria-label="Close" onClick={this.closeMessage}><span aria-hidden="true">&times;</span></button>
                {this.state.message}
              </div>
            : false
        )
    }
}

document.addEventListener('DOMContentLoaded', () => {
    const references = {};
    let isSubmitClicked = false;

    document.forms[0].addEventListener('submit', (e) =>{
        isSubmitClicked = true;
        e.preventDefault();
    });

    document.forms[0].addEventListener('ajax:success', (result) => {
        // console.log('ajax:success', result.detail[0]);
        references.AlertMessage.closeMessage();

        const action = {
            'youtubeSearchList': () => {
                references.MediaList.addResults(result.detail[0], isSubmitClicked);
            },
            'youtubeCommentThreads': () => {

            },
        };
        action[result.detail[0].apiName]();
        
        isSubmitClicked = false;
    });

    document.forms[0].addEventListener('ajax:error', (response) => {
        console.log('ajax:error', response);
        isSubmitClicked = false;
        references.AlertMessage.showMessage(response.detail[0].errors, 'danger');
    });

    ReactDOM.render(
        <AlertMessage errors={[]} type="danger" references={references} />,
        document.getElementById('message-area'),
    );

    ReactDOM.render(
        <MediaList
            result={{ nextPageToken: '', items: [], pageInfo: { totalResults: 0 } }}
            references={references} />,
        document.getElementById('search-results'),
    );
});
