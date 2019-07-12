
const initialState = {
    cmntsrch: {
        headers: [
            { key: 'videoId', name: '動画ID' },
            { key: 'title', name: 'タイトル' },
        ],
        rows: [],
    },
};

export default function reducer(state = initialState, action) {
    switch (action.type) {
        case ADD_ROWS:
            return state;
        default:
            return state;
    }
}