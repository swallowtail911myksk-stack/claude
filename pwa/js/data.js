// ===== TOEIC 問題データ (Part 5 形式) =====
const QUESTIONS = [
    {
        id: "q001",
        sentence: "The meeting has been ___ until next Monday due to the manager's business trip.",
        choices: ["postponed", "postponing", "postpone", "postpones"],
        correctIndex: 0,
        explanation: "has been + 過去分詞で現在完了の受動態。会議は「延期された」という受け身の意味なので postponed が正解。",
        category: "時制", difficulty: "中級"
    },
    {
        id: "q002",
        sentence: "All employees must submit their expense reports ___ the end of each month.",
        choices: ["by", "until", "from", "since"],
        correctIndex: 0,
        explanation: "by は「〜までに」という期限を表す前置詞。until は「〜まで（ずっと）」で継続を表す。期限なので by が正解。",
        category: "前置詞", difficulty: "初級"
    },
    {
        id: "q003",
        sentence: "The new software is ___ more efficient than the previous version.",
        choices: ["significantly", "significant", "significance", "signify"],
        correctIndex: 0,
        explanation: "比較級 more efficient を修飾するには副詞が必要。significantly（著しく）が正解。",
        category: "品詞", difficulty: "中級"
    },
    {
        id: "q004",
        sentence: "Ms. Tanaka is responsible ___ managing the entire marketing department.",
        choices: ["for", "to", "with", "of"],
        correctIndex: 0,
        explanation: "be responsible for 〜 で「〜に対して責任がある」という意味のイディオム。",
        category: "前置詞", difficulty: "初級"
    },
    {
        id: "q005",
        sentence: "___ the heavy rain, the outdoor event was held as scheduled.",
        choices: ["Despite", "Because", "Although", "However"],
        correctIndex: 0,
        explanation: "Despite は前置詞で後ろに名詞が来る。「大雨にもかかわらず」。Although は接続詞なので節が必要。",
        category: "接続詞", difficulty: "中級"
    },
    {
        id: "q006",
        sentence: "The company decided to ___ its headquarters to a larger building downtown.",
        choices: ["relocate", "relocation", "relocated", "relocating"],
        correctIndex: 0,
        explanation: "to の後ろには動詞の原形が来る。decide to do で「〜することを決める」。",
        category: "文法", difficulty: "初級"
    },
    {
        id: "q007",
        sentence: "Customer satisfaction has increased ___ since the new policy was implemented.",
        choices: ["steadily", "steady", "steadiness", "steadied"],
        correctIndex: 0,
        explanation: "動詞 increased を修飾するので副詞 steadily（着実に）が正解。",
        category: "品詞", difficulty: "中級"
    },
    {
        id: "q008",
        sentence: "The report should be completed ___ Friday at the latest.",
        choices: ["by", "on", "in", "at"],
        correctIndex: 0,
        explanation: "「遅くとも金曜日までに」という期限を表す by が正解。at the latest で「遅くとも」。",
        category: "前置詞", difficulty: "初級"
    },
    {
        id: "q009",
        sentence: "The factory will be closed for two weeks ___ annual maintenance can be performed.",
        choices: ["so that", "in order", "due to", "because of"],
        correctIndex: 0,
        explanation: "so that + 主語 + 動詞 で「〜できるように」という目的を表す。in order の後には to が必要。",
        category: "接続詞", difficulty: "上級"
    },
    {
        id: "q010",
        sentence: "Each department head is required to give a ___ presentation at the annual meeting.",
        choices: ["brief", "briefly", "brevity", "briefed"],
        correctIndex: 0,
        explanation: "名詞 presentation を修飾するので形容詞 brief（簡潔な）が正解。",
        category: "品詞", difficulty: "初級"
    },
    {
        id: "q011",
        sentence: "The sales figures for this quarter were ___ than those of the previous year.",
        choices: ["higher", "highest", "highly", "high"],
        correctIndex: 0,
        explanation: "than があるので比較級が必要。higher than で「〜より高い」。",
        category: "文法", difficulty: "初級"
    },
    {
        id: "q012",
        sentence: "Applicants who have ___ in international trade will be given preference.",
        choices: ["experience", "experienced", "experiencing", "experiences"],
        correctIndex: 0,
        explanation: "have の後に名詞が来る形。have experience in 〜 で「〜の経験がある」。不可算名詞として使う。",
        category: "語彙", difficulty: "中級"
    },
    {
        id: "q013",
        sentence: "The conference room is ___ equipped with the latest audiovisual technology.",
        choices: ["fully", "full", "fulfill", "fullness"],
        correctIndex: 0,
        explanation: "過去分詞 equipped を修飾するので副詞 fully（完全に）が正解。",
        category: "品詞", difficulty: "中級"
    },
    {
        id: "q014",
        sentence: "___ Mr. Kim nor Ms. Park will be available for the meeting on Thursday.",
        choices: ["Neither", "Either", "Both", "Not only"],
        correctIndex: 0,
        explanation: "neither A nor B で「AもBも〜ない」。nor と組み合わせるのは neither。",
        category: "文法", difficulty: "中級"
    },
    {
        id: "q015",
        sentence: "The warranty on this product is ___ for a period of two years from the date of purchase.",
        choices: ["valid", "validate", "validity", "validly"],
        correctIndex: 0,
        explanation: "is の後に補語として形容詞が必要。valid（有効な）が正解。",
        category: "品詞", difficulty: "中級"
    },
    {
        id: "q016",
        sentence: "Please make sure to ___ all the necessary documents before the deadline.",
        choices: ["submit", "submission", "submitted", "submitting"],
        correctIndex: 0,
        explanation: "make sure to の後ろは動詞の原形。submit（提出する）が正解。",
        category: "文法", difficulty: "初級"
    },
    {
        id: "q017",
        sentence: "The hotel offers a wide ___ of services to meet the needs of business travelers.",
        choices: ["range", "ranging", "ranged", "ranger"],
        correctIndex: 0,
        explanation: "a wide range of 〜 で「幅広い〜」という定型表現。",
        category: "語彙", difficulty: "中級"
    },
    {
        id: "q018",
        sentence: "Employees are encouraged to participate ___ the company's wellness program.",
        choices: ["in", "for", "with", "to"],
        correctIndex: 0,
        explanation: "participate in 〜 で「〜に参加する」。in が正しい前置詞。",
        category: "前置詞", difficulty: "初級"
    },
    {
        id: "q019",
        sentence: "The CEO ___ that the company would expand into Asian markets next year.",
        choices: ["announced", "announcing", "announcement", "announce"],
        correctIndex: 0,
        explanation: "主語 The CEO に対する述語動詞が必要。過去形 announced が正解。",
        category: "文法", difficulty: "初級"
    },
    {
        id: "q020",
        sentence: "The new regulation will take ___ at the beginning of next month.",
        choices: ["effect", "effective", "effectively", "effects"],
        correctIndex: 0,
        explanation: "take effect で「施行される、効力を発する」という定型表現。",
        category: "語彙", difficulty: "上級"
    },
    {
        id: "q021",
        sentence: "The budget proposal needs to be ___ by the board of directors before implementation.",
        choices: ["approved", "approving", "approval", "approves"],
        correctIndex: 0,
        explanation: "needs to be + 過去分詞で受動態。「承認される必要がある」。",
        category: "文法", difficulty: "中級"
    },
    {
        id: "q022",
        sentence: "We would appreciate it if you could respond ___ your earliest convenience.",
        choices: ["at", "by", "in", "on"],
        correctIndex: 0,
        explanation: "at your earliest convenience で「ご都合のつき次第」というビジネス定型表現。",
        category: "前置詞", difficulty: "上級"
    },
    {
        id: "q023",
        sentence: "The training session is ___ for all new employees during their first week.",
        choices: ["mandatory", "mandatorily", "mandate", "mandated"],
        correctIndex: 0,
        explanation: "is の後に補語として形容詞が必要。mandatory（必須の）が正解。",
        category: "品詞", difficulty: "上級"
    },
    {
        id: "q024",
        sentence: "___ reviewing the contract, please sign and return it to our office.",
        choices: ["After", "During", "While", "Meanwhile"],
        correctIndex: 0,
        explanation: "After + 動名詞で「〜した後に」。During は名詞を取り、While は節を取る。",
        category: "接続詞", difficulty: "中級"
    },
    {
        id: "q025",
        sentence: "The company's profits have grown ___ over the past five years.",
        choices: ["considerably", "considerable", "consider", "consideration"],
        correctIndex: 0,
        explanation: "動詞 have grown を修飾するので副詞 considerably（かなり）が正解。",
        category: "品詞", difficulty: "上級"
    },
    {
        id: "q026",
        sentence: "Please ensure that all safety ___ are followed during the construction.",
        choices: ["procedures", "procedural", "proceed", "proceeding"],
        correctIndex: 0,
        explanation: "all の後に名詞の複数形が必要。safety procedures で「安全手順」。",
        category: "語彙", difficulty: "中級"
    },
    {
        id: "q027",
        sentence: "The manager asked the team to ___ a detailed report by next week.",
        choices: ["prepare", "preparation", "prepared", "preparatory"],
        correctIndex: 0,
        explanation: "asked someone to do で「〜するよう頼んだ」。to の後は動詞の原形。",
        category: "文法", difficulty: "初級"
    },
    {
        id: "q028",
        sentence: "The product launch was delayed ___ unexpected supply chain issues.",
        choices: ["due to", "so that", "even though", "as long as"],
        correctIndex: 0,
        explanation: "due to + 名詞で「〜が原因で」。後ろに名詞句が来ているので due to が正解。",
        category: "接続詞", difficulty: "中級"
    },
    {
        id: "q029",
        sentence: "Visitors must obtain a security pass ___ entering the building.",
        choices: ["before", "after", "while", "during"],
        correctIndex: 0,
        explanation: "建物に入る「前に」セキュリティパスを取得する必要がある。文脈から before が正解。",
        category: "接続詞", difficulty: "初級"
    },
    {
        id: "q030",
        sentence: "The annual report provides a ___ overview of the company's financial performance.",
        choices: ["comprehensive", "comprehensively", "comprehend", "comprehension"],
        correctIndex: 0,
        explanation: "名詞 overview を修飾するので形容詞 comprehensive（包括的な）が正解。",
        category: "品詞", difficulty: "上級"
    }
];

// ===== TOEIC 単語データ =====
const VOCABULARY = [
    { id: "v001", english: "implement", japanese: "実施する、導入する", partOfSpeech: "動詞", exampleEn: "The company plans to implement a new training program.", exampleJa: "会社は新しい研修プログラムを導入する予定です。", level: "必須" },
    { id: "v002", english: "revenue", japanese: "収益、歳入", partOfSpeech: "名詞", exampleEn: "The company's revenue increased by 15% this year.", exampleJa: "会社の収益は今年15%増加しました。", level: "必須" },
    { id: "v003", english: "accommodate", japanese: "収容する、対応する", partOfSpeech: "動詞", exampleEn: "The hotel can accommodate up to 500 guests.", exampleJa: "そのホテルは最大500人の宿泊客を収容できます。", level: "発展" },
    { id: "v004", english: "deadline", japanese: "締め切り、期限", partOfSpeech: "名詞", exampleEn: "Please make sure to meet the deadline for the project.", exampleJa: "プロジェクトの締め切りに間に合うようにしてください。", level: "基礎" },
    { id: "v005", english: "negotiate", japanese: "交渉する", partOfSpeech: "動詞", exampleEn: "We need to negotiate the terms of the contract.", exampleJa: "契約の条件を交渉する必要があります。", level: "必須" },
    { id: "v006", english: "quarterly", japanese: "四半期ごとの", partOfSpeech: "形容詞", exampleEn: "The quarterly report will be published next week.", exampleJa: "四半期報告書は来週発行されます。", level: "必須" },
    { id: "v007", english: "eligible", japanese: "資格がある、適格な", partOfSpeech: "形容詞", exampleEn: "All full-time employees are eligible for the bonus.", exampleJa: "すべての正社員がボーナスの対象となります。", level: "発展" },
    { id: "v008", english: "schedule", japanese: "予定する、スケジュール", partOfSpeech: "動詞/名詞", exampleEn: "The meeting is scheduled for 3 PM tomorrow.", exampleJa: "会議は明日午後3時に予定されています。", level: "基礎" },
    { id: "v009", english: "merchandise", japanese: "商品、製品", partOfSpeech: "名詞", exampleEn: "The store offers a wide variety of merchandise.", exampleJa: "その店は幅広い種類の商品を提供しています。", level: "必須" },
    { id: "v010", english: "approximately", japanese: "おおよそ、約", partOfSpeech: "副詞", exampleEn: "The project will take approximately three months.", exampleJa: "プロジェクトの完了にはおよそ3ヶ月かかります。", level: "基礎" },
    { id: "v011", english: "compliance", japanese: "法令遵守、コンプライアンス", partOfSpeech: "名詞", exampleEn: "The company must ensure compliance with all regulations.", exampleJa: "会社はすべての規制を遵守しなければなりません。", level: "発展" },
    { id: "v012", english: "submit", japanese: "提出する", partOfSpeech: "動詞", exampleEn: "Please submit your application by Friday.", exampleJa: "金曜日までに申請書を提出してください。", level: "基礎" },
    { id: "v013", english: "initiative", japanese: "取り組み、イニシアチブ", partOfSpeech: "名詞", exampleEn: "The company launched a new sustainability initiative.", exampleJa: "会社は新しい持続可能性の取り組みを開始しました。", level: "発展" },
    { id: "v014", english: "efficient", japanese: "効率的な", partOfSpeech: "形容詞", exampleEn: "The new system is much more efficient than the old one.", exampleJa: "新しいシステムは古いものよりもはるかに効率的です。", level: "必須" },
    { id: "v015", english: "anticipate", japanese: "予想する、見込む", partOfSpeech: "動詞", exampleEn: "We anticipate strong demand for the new product.", exampleJa: "新製品に対する強い需要を見込んでいます。", level: "発展" },
    { id: "v016", english: "regarding", japanese: "〜に関して", partOfSpeech: "前置詞", exampleEn: "I have a question regarding the new policy.", exampleJa: "新しいポリシーに関して質問があります。", level: "基礎" },
    { id: "v017", english: "adjacent", japanese: "隣接した、近くの", partOfSpeech: "形容詞", exampleEn: "The parking lot is adjacent to the main building.", exampleJa: "駐車場はメインビルに隣接しています。", level: "発展" },
    { id: "v018", english: "confirm", japanese: "確認する", partOfSpeech: "動詞", exampleEn: "Could you confirm the reservation for tonight?", exampleJa: "今夜の予約を確認していただけますか？", level: "基礎" },
    { id: "v019", english: "substantial", japanese: "かなりの、実質的な", partOfSpeech: "形容詞", exampleEn: "The company made a substantial investment in technology.", exampleJa: "会社はテクノロジーにかなりの投資をしました。", level: "必須" },
    { id: "v020", english: "inventory", japanese: "在庫、棚卸し", partOfSpeech: "名詞", exampleEn: "We need to check the inventory before placing a new order.", exampleJa: "新しい注文をする前に在庫を確認する必要があります。", level: "必須" },
    { id: "v021", english: "attend", japanese: "出席する", partOfSpeech: "動詞", exampleEn: "Over 200 people attended the conference.", exampleJa: "200人以上がその会議に出席しました。", level: "基礎" },
    { id: "v022", english: "preliminary", japanese: "予備的な、準備の", partOfSpeech: "形容詞", exampleEn: "The preliminary results of the survey are promising.", exampleJa: "調査の予備的な結果は有望です。", level: "発展" },
    { id: "v023", english: "collaborate", japanese: "協力する、共同で取り組む", partOfSpeech: "動詞", exampleEn: "The two departments will collaborate on the project.", exampleJa: "2つの部署がそのプロジェクトで協力します。", level: "必須" },
    { id: "v024", english: "warranty", japanese: "保証、保証書", partOfSpeech: "名詞", exampleEn: "The product comes with a two-year warranty.", exampleJa: "その製品には2年間の保証がついています。", level: "必須" },
    { id: "v025", english: "reimburse", japanese: "払い戻す、弁償する", partOfSpeech: "動詞", exampleEn: "The company will reimburse you for travel expenses.", exampleJa: "会社が旅費を払い戻します。", level: "発展" },
    { id: "v026", english: "affordable", japanese: "手頃な価格の", partOfSpeech: "形容詞", exampleEn: "We offer high-quality products at affordable prices.", exampleJa: "手頃な価格で高品質の製品を提供しています。", level: "基礎" },
    { id: "v027", english: "subsequent", japanese: "その後の、続いて起こる", partOfSpeech: "形容詞", exampleEn: "Subsequent meetings will be held every two weeks.", exampleJa: "その後の会議は2週間ごとに開催されます。", level: "発展" },
    { id: "v028", english: "promote", japanese: "昇進させる、促進する", partOfSpeech: "動詞", exampleEn: "She was promoted to senior manager last month.", exampleJa: "彼女は先月シニアマネージャーに昇進しました。", level: "基礎" },
    { id: "v029", english: "feasible", japanese: "実行可能な", partOfSpeech: "形容詞", exampleEn: "The committee determined that the plan was feasible.", exampleJa: "委員会はその計画が実行可能であると判断しました。", level: "発展" },
    { id: "v030", english: "exceed", japanese: "超える、上回る", partOfSpeech: "動詞", exampleEn: "Sales this year exceeded our expectations.", exampleJa: "今年の売上は我々の期待を上回りました。", level: "必須" }
];
