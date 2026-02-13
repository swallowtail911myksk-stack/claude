// ===== TOEIC Daily アプリ =====

const App = (() => {
    // ----- ストレージ管理 -----
    const Storage = {
        get(key, fallback) {
            try {
                const data = localStorage.getItem('toeic_' + key);
                return data ? JSON.parse(data) : fallback;
            } catch { return fallback; }
        },
        set(key, value) {
            localStorage.setItem('toeic_' + key, JSON.stringify(value));
        }
    };

    function todayStr() {
        const d = new Date();
        return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
    }

    function yesterdayStr() {
        const d = new Date();
        d.setDate(d.getDate() - 1);
        return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
    }

    function dayOfWeek(dateStr) {
        const days = ['日','月','火','水','木','金','土'];
        return days[new Date(dateStr).getDay()];
    }

    // ----- 状態 -----
    let streak = Storage.get('streak', { current: 0, longest: 0, lastDate: '', totalDays: 0 });
    let todayRecord = Storage.get('today_' + todayStr(), { correct: 0, total: 0, words: 0 });
    let questionResults = Storage.get('qResults', []);
    let vocabStatuses = Storage.get('vocabStatuses', {});
    let dailyRecords = Storage.get('dailyRecords', {});

    // クイズ状態
    let quizQuestions = [];
    let quizIndex = 0;
    let quizAnswered = false;
    let quizResults = [];
    let quizMode = 'daily';

    // 単語状態
    let vocabWords = [];
    let vocabIndex = 0;
    let vocabShowMeaning = false;
    let vocabKnown = 0;
    let vocabUnknown = 0;

    // ----- 保存 -----
    function save() {
        Storage.set('streak', streak);
        Storage.set('today_' + todayStr(), todayRecord);
        Storage.set('qResults', questionResults);
        Storage.set('vocabStatuses', vocabStatuses);
        dailyRecords[todayStr()] = todayRecord;
        Storage.set('dailyRecords', dailyRecords);
    }

    function recordStudyDay() {
        const today = todayStr();
        if (streak.lastDate === today) return;
        if (streak.lastDate === yesterdayStr()) {
            streak.current += 1;
        } else {
            streak.current = 1;
        }
        streak.longest = Math.max(streak.longest, streak.current);
        streak.lastDate = today;
        streak.totalDays += 1;
        save();
    }

    // ----- 配列ユーティリティ -----
    function shuffle(arr) {
        const a = [...arr];
        for (let i = a.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [a[i], a[j]] = [a[j], a[i]];
        }
        return a;
    }

    // ----- 画面切り替え -----
    function showScreen(id) {
        document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
        document.getElementById('screen-' + id).classList.add('active');
        if (id === 'home') refreshHome();
        if (id === 'stats') refreshStats();
        window.scrollTo(0, 0);
    }

    // ===== ホーム画面 =====
    function refreshHome() {
        todayRecord = Storage.get('today_' + todayStr(), { correct: 0, total: 0, words: 0 });

        document.getElementById('home-streak').textContent = streak.current;
        document.getElementById('home-best-streak').textContent = streak.longest + '日';

        const total = todayRecord.total;
        const correct = todayRecord.correct;
        document.getElementById('home-correct').textContent = `${correct}/${total}`;
        document.getElementById('home-words').textContent = todayRecord.words || 0;
        document.getElementById('home-accuracy').textContent = total > 0 ? Math.round(correct / total * 100) + '%' : '-';

        // 曜日ドット
        const dotsEl = document.getElementById('home-week-dots');
        const dayNames = ['月','火','水','木','金','土','日'];
        const today = new Date();
        const todayDay = today.getDay(); // 0=日
        dotsEl.innerHTML = dayNames.map((name, i) => {
            // 月=0 ... 日=6 in our array, but JS: 日=0, 月=1 ... 土=6
            const jsDay = (i + 1) % 7; // 月→1, 火→2, ... 日→0
            const diff = jsDay - todayDay;
            const d = new Date(today);
            d.setDate(d.getDate() + diff);
            const dStr = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
            const studied = dailyRecords[dStr] && dailyRecords[dStr].total > 0;
            return `<div class="week-dot">
                <div class="week-dot-label">${name}</div>
                <div class="week-dot-circle ${studied ? 'active' : ''}">${studied ? '✓' : ''}</div>
            </div>`;
        }).join('');
    }

    // ===== クイズ =====
    function startQuiz(mode) {
        quizMode = mode;
        if (mode === 'review') {
            const wrongIds = new Set(questionResults.filter(r => !r.isCorrect).map(r => r.qId));
            const correctIds = new Set(questionResults.filter(r => r.isCorrect).map(r => r.qId));
            const reviewIds = [...wrongIds].filter(id => !correctIds.has(id));
            quizQuestions = shuffle(QUESTIONS.filter(q => reviewIds.includes(q.id)));
            if (quizQuestions.length === 0) {
                quizQuestions = shuffle(QUESTIONS).slice(0, 5);
            }
        } else {
            quizQuestions = shuffle(QUESTIONS).slice(0, 5);
        }
        quizIndex = 0;
        quizAnswered = false;
        quizResults = [];
        showScreen('quiz');
        renderQuestion();
    }

    function renderQuestion() {
        const q = quizQuestions[quizIndex];
        if (!q) return;

        document.getElementById('quiz-counter').textContent = `${quizIndex + 1} / ${quizQuestions.length}`;
        document.getElementById('quiz-progress').style.width = `${(quizIndex / quizQuestions.length) * 100}%`;

        // タグ
        const diffColor = { '初級': 'green', '中級': 'orange', '上級': 'red' };
        document.getElementById('quiz-tags').innerHTML =
            `<span class="tag indigo">${q.category}</span>` +
            `<span class="tag ${diffColor[q.difficulty] || 'orange'}">${q.difficulty}</span>`;

        // 問題文（___を強調）
        document.getElementById('quiz-sentence').innerHTML = q.sentence.replace(/___/g, '<strong style="color:var(--indigo);border-bottom:2px solid var(--indigo)">______</strong>');

        // 選択肢
        const letters = ['A', 'B', 'C', 'D'];
        document.getElementById('quiz-choices').innerHTML = q.choices.map((c, i) =>
            `<button class="choice-btn" onclick="App.selectAnswer(${i})" id="choice-${i}">
                <span class="choice-letter">${letters[i]}</span>
                <span class="choice-text">${c}</span>
                <span class="choice-icon"></span>
            </button>`
        ).join('');

        // 解説・次へボタンを隠す
        document.getElementById('quiz-explanation').classList.add('hidden');
        document.getElementById('quiz-next-btn').classList.add('hidden');
        quizAnswered = false;
    }

    function selectAnswer(index) {
        if (quizAnswered) return;
        quizAnswered = true;

        const q = quizQuestions[quizIndex];
        const isCorrect = index === q.correctIndex;

        // 記録
        questionResults.push({ qId: q.id, selected: index, isCorrect, date: todayStr() });
        todayRecord.total += 1;
        if (isCorrect) todayRecord.correct += 1;
        recordStudyDay();
        save();

        quizResults.push({ isCorrect });

        // 選択肢の見た目更新
        for (let i = 0; i < q.choices.length; i++) {
            const btn = document.getElementById('choice-' + i);
            btn.classList.add('disabled');
            if (i === q.correctIndex) {
                btn.classList.add('correct');
                btn.querySelector('.choice-icon').textContent = '✓';
            } else if (i === index && !isCorrect) {
                btn.classList.add('wrong');
                btn.querySelector('.choice-icon').textContent = '✕';
            }
        }

        // 解説表示
        document.getElementById('quiz-explanation-text').textContent = q.explanation;
        document.getElementById('quiz-explanation').classList.remove('hidden');

        // 次へボタン
        const nextBtn = document.getElementById('quiz-next-btn');
        nextBtn.textContent = quizIndex + 1 >= quizQuestions.length ? '結果を見る' : '次の問題へ';
        nextBtn.classList.remove('hidden');
    }

    function nextQuestion() {
        if (quizIndex + 1 >= quizQuestions.length) {
            showQuizResult();
        } else {
            quizIndex++;
            renderQuestion();
            window.scrollTo(0, 0);
        }
    }

    function showQuizResult() {
        const correct = quizResults.filter(r => r.isCorrect).length;
        const total = quizResults.length;
        const pct = total > 0 ? Math.round(correct / total * 100) : 0;

        let icon, message;
        if (pct >= 90) { icon = '⭐'; message = '素晴らしい！'; }
        else if (pct >= 70) { icon = '👍'; message = 'よくできました！'; }
        else if (pct >= 50) { icon = '😊'; message = 'もう少し！'; }
        else { icon = '📖'; message = '復習しましょう！'; }

        document.getElementById('result-icon').textContent = icon;
        document.getElementById('result-message').textContent = message;
        document.getElementById('result-correct').textContent = correct;
        document.getElementById('result-total').textContent = total;
        document.getElementById('result-accuracy').textContent = pct;

        showScreen('result');

        // バーアニメーション
        setTimeout(() => {
            document.getElementById('result-bar').style.width = pct + '%';
            const color = pct >= 80 ? 'var(--green)' : pct >= 50 ? 'var(--orange)' : 'var(--red)';
            document.getElementById('result-bar').style.background = color;
        }, 100);
    }

    function retryQuiz() {
        startQuiz(quizMode);
    }

    // ===== 単語カード =====
    function startVocabulary() {
        const now = Date.now();
        // 復習が必要な単語を優先
        const needReview = VOCABULARY.filter(w => {
            const s = vocabStatuses[w.id];
            if (!s) return true;
            return s.nextReview <= now;
        });

        if (needReview.length >= 10) {
            vocabWords = shuffle(needReview).slice(0, 10);
        } else {
            const rest = VOCABULARY.filter(w => !needReview.find(n => n.id === w.id));
            vocabWords = shuffle([...needReview, ...shuffle(rest)]).slice(0, 10);
        }

        vocabIndex = 0;
        vocabShowMeaning = false;
        vocabKnown = 0;
        vocabUnknown = 0;
        showScreen('vocab');
        renderVocabCard();
    }

    function renderVocabCard() {
        const w = vocabWords[vocabIndex];
        if (!w) return;

        document.getElementById('vocab-counter').textContent = `残り ${vocabWords.length - vocabIndex} 語`;
        document.getElementById('vocab-progress').style.width = `${(vocabIndex / vocabWords.length) * 100}%`;

        document.getElementById('flash-level').textContent = w.level;
        document.getElementById('flash-pos').textContent = w.partOfSpeech;
        document.getElementById('flash-word').textContent = w.english;
        document.getElementById('flash-meaning').textContent = w.japanese;
        document.getElementById('flash-example-en').textContent = w.exampleEn;
        document.getElementById('flash-example-ja').textContent = w.exampleJa;

        // 意味を隠す
        vocabShowMeaning = false;
        document.getElementById('flash-divider').classList.add('hidden');
        document.getElementById('flash-meaning').classList.add('hidden');
        document.getElementById('flash-example').classList.add('hidden');
        document.getElementById('flash-tap-hint').classList.remove('hidden');
        document.getElementById('vocab-actions').classList.add('hidden');
    }

    function toggleMeaning() {
        vocabShowMeaning = !vocabShowMeaning;
        document.getElementById('flash-divider').classList.toggle('hidden', !vocabShowMeaning);
        document.getElementById('flash-meaning').classList.toggle('hidden', !vocabShowMeaning);
        document.getElementById('flash-example').classList.toggle('hidden', !vocabShowMeaning);
        document.getElementById('flash-tap-hint').classList.toggle('hidden', vocabShowMeaning);
        document.getElementById('vocab-actions').classList.toggle('hidden', !vocabShowMeaning);
    }

    function markKnown() {
        const w = vocabWords[vocabIndex];
        let s = vocabStatuses[w.id] || { known: 0, unknown: 0, nextReview: 0 };
        s.known += 1;
        const days = Math.min(Math.pow(2, s.known), 30);
        s.nextReview = Date.now() + days * 86400000;
        vocabStatuses[w.id] = s;

        todayRecord.words = (todayRecord.words || 0) + 1;
        vocabKnown++;
        recordStudyDay();
        save();
        vocabNext();
    }

    function markUnknown() {
        const w = vocabWords[vocabIndex];
        let s = vocabStatuses[w.id] || { known: 0, unknown: 0, nextReview: 0 };
        s.unknown += 1;
        s.nextReview = Date.now(); // すぐ復習
        vocabStatuses[w.id] = s;

        todayRecord.words = (todayRecord.words || 0) + 1;
        vocabUnknown++;
        recordStudyDay();
        save();
        vocabNext();
    }

    function vocabNext() {
        if (vocabIndex + 1 >= vocabWords.length) {
            document.getElementById('vocab-known-count').textContent = vocabKnown;
            document.getElementById('vocab-unknown-count').textContent = vocabUnknown;
            showScreen('vocab-result');
        } else {
            vocabIndex++;
            renderVocabCard();
        }
    }

    // ===== 統計画面 =====
    function refreshStats() {
        document.getElementById('stats-streak').textContent = streak.current;
        document.getElementById('stats-best').textContent = streak.longest;
        document.getElementById('stats-total-days').textContent = streak.totalDays;

        // 全体成績
        const totalQ = questionResults.length;
        const totalCorrect = questionResults.filter(r => r.isCorrect).length;
        document.getElementById('stats-total-q').textContent = totalQ + ' 問';
        document.getElementById('stats-overall-acc').textContent = totalQ > 0 ? Math.round(totalCorrect / totalQ * 100) + '%' : '-';

        // 週間チャート
        renderWeeklyChart();

        // 単語進捗
        const learned = Object.values(vocabStatuses).filter(s => s.known >= 3 && s.known > s.unknown * 2).length;
        const totalWords = VOCABULARY.length;
        const pct = totalWords > 0 ? Math.round(learned / totalWords * 100) : 0;
        document.getElementById('stats-vocab-progress').textContent = `${learned} / ${totalWords}`;
        document.getElementById('stats-vocab-pct').textContent = pct + '%';
        document.getElementById('stats-vocab-ring').setAttribute('stroke-dasharray', `${pct}, 100`);
    }

    function renderWeeklyChart() {
        const chart = document.getElementById('stats-weekly-chart');
        const dayNames = ['月','火','水','木','金','土','日'];
        const today = new Date();

        let weeklyTotal = 0, weeklyCorrect = 0;
        const bars = [];

        for (let i = 6; i >= 0; i--) {
            const d = new Date(today);
            d.setDate(d.getDate() - i);
            const dStr = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
            const dayName = dayNames[(d.getDay() + 6) % 7]; // 月=0表記に変換

            const rec = dailyRecords[dStr];
            let acc = 0;
            let hasData = false;
            if (rec && rec.total > 0) {
                acc = Math.round(rec.correct / rec.total * 100);
                weeklyTotal += rec.total;
                weeklyCorrect += rec.correct;
                hasData = true;
            }

            const color = acc >= 80 ? 'green' : acc >= 50 ? 'orange' : acc > 0 ? 'red' : '';
            const height = hasData ? Math.max(8, acc) : 6;

            bars.push(`<div class="chart-bar-wrap">
                ${hasData ? `<div class="chart-bar-pct">${acc}%</div>` : ''}
                <div class="chart-bar ${color}" style="height:${height}px"></div>
                <div class="chart-day">${dayName}</div>
            </div>`);
        }

        chart.innerHTML = bars.join('');

        const weeklyAcc = weeklyTotal > 0 ? Math.round(weeklyCorrect / weeklyTotal * 100) : 0;
        document.getElementById('stats-weekly-acc').textContent = weeklyTotal > 0 ? `正答率 ${weeklyAcc}%` : '正答率 -';
    }

    // ===== 初期化 =====
    function init() {
        // Service Worker 登録
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('./sw.js').catch(() => {});
        }
        refreshHome();
    }

    // DOM読み込み完了後に初期化
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }

    // 公開API
    return {
        showScreen,
        startQuiz,
        selectAnswer,
        nextQuestion,
        retryQuiz,
        startVocabulary,
        toggleMeaning,
        markKnown,
        markUnknown
    };
})();
