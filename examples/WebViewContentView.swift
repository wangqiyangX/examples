//
//  WebViewContentView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/7.
//

import SwiftUI
import WebKit

struct WebViewContentView: View {
    var body: some View {
        WebView(url: URL(string: "https://www.webkit.org"))
    }
}

@MainActor
@Observable
class WebViewModel {
    var webPage: WebPage = WebPage()
    var config: WebPage.Configuration = WebPage.Configuration()
    var fontSize: Double = 16

    var customCSS: String {
        """
        *, *::before, *::after {
          box-sizing: border-box;
          max-width: 100%;
        }
        html, body {
          margin: 0;
          padding: 0;
          overflow-x: hidden;
          width: 100%;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", sans-serif;
            font-size: \(fontSize)px;
            line-height: 1.5;
            color: #222;
            background-color: #fff;
        }
        h2 {
          font-size: 2em;           /* 字体大小 */
          font-weight: 900;         /* 字体加粗 */
          color: #333;              /* 字体颜色 */
          margin-top: 20px;         /* 上边距 */
          margin-bottom: 10px;      /* 下边距 */
          line-height: 1.4;         /* 行高 */
          letter-spacing: 0.5px;    /* 字符间距 */
        }
        img {
            display: block;
            max-width: 100%;
            height: auto;
        }
        div.mainContent {
            margin: 10px;
        }
        """
    }

    func updateInnerHTML() {
        webPage.reload(fromOrigin: true)
    }

    func loadInnerHTML(htmlString: String) {
        let botAgent = """
            Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1 (Applebot/0.1; +http://www.apple.com/go/applebot)
            """

        var configuration = WebPage.Configuration()
        configuration.supportsAdaptiveImageGlyph = true

        let page = WebPage(configuration: configuration)
        page.customUserAgent = botAgent
        page.load(
            html: """
                    <!DOCTYPE html>
                    <html lang="zh">
                    <head>
                        <meta charset="UTF-8" />
                        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                        <title>Document</title>
                        <style>
                            \(customCSS)
                        </style>
                    </head>
                    <body>
                        <div class="mainContent">
                            \(htmlString)
                        </div>
                    </body>
                    </html>
                """
        )

        webPage = page
    }
}

struct WebKitDemoView: View {
    @State private var viewModel = WebViewModel()

    var body: some View {
        List {
            Slider(value: $viewModel.fontSize, in: 16...44)
        }
        Group {
            if viewModel.webPage.isLoading {
                ProgressView()
            } else {
                WebView(viewModel.webPage)
                    .webViewBackForwardNavigationGestures(.disabled)
                    .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            }
        }
        .task {
            viewModel.loadInnerHTML(htmlString: itemContent)
        }
        .onChange(of: viewModel.fontSize) { oldValue, newValue in
            viewModel.loadInnerHTML(htmlString: itemContent)
        }
    }

    let itemContent: String = """
                        <img src="https://s3.ifanr.com/images/ep/cover-images/qi_ha_lei_de_nv_ren_cover.jpg" alt="Article Cover Image" style="display: block; margin: 0 auto;" referrerpolicy="no-referrer"><br> <div style="padding: 0 14px;"> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">🍎</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">苹果 18 寸大折叠或无缘 2026 年量产</p> </div> </div> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">📅</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">微信员工否认「调时间恢复过期文件」</p> </div> </div> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">🔥</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">OpenAI 工程师：本周令人兴奋</p> </div> </div> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">🚗</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">鸿蒙智行最贵车型：大定破万台</p> </div> </div> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">📢</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">小米开源声音理解大模型</p> </div> </div> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">👥</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">Anthropic 新技术：控制模型的性格特征</p> </div> </div> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">⚙️</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">阿里通义语音大牛被曝转投京东</p> </div> </div> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">💡</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">Anthropic CEO：AI 问题现阶段已经无法回避</p> </div> </div> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">🧠</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">阿里通义发布全新文生图模型</p> </div> </div> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">🗺️</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">高德地图 2025 发布：内置生活智能体</p> </div> </div> <div> <p style="float: left; margin-right: 6px; margin-bottom: 0; width: 30px;">📸</p> <div style="margin-bottom: 0; width: 88%;"> <p style="margin-bottom: 0;">DJI Mini 5 Pro 曝光：搭载一英寸传感器</p> </div> </div> </div> <section><img src="https://s3.ifanr.com/images/ep/common-images/xin_wen.png!720" alt="重磅" referrerpolicy="no-referrer"></section> <h3>苹果 18 寸大折叠或无缘 2026 年量产</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/a3bc7b36-7c67-4373-8f38-5273efb45de6.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>据 MacRumors 报道，苹果目前除了预计 2026 年底推出的折叠屏 iPhone，还在研发一款大尺寸的折叠屏设备（MacBook 和 iPad 混合型产品）。但据分析师 Jeff Pu 表示，<strong>苹果的大号折叠屏设备或会推迟。</strong></p> <p>Jeff Pu 指出，<strong>传闻已久的苹果 18.8 英寸大折叠产品将不在 2026 年第四季度开始大规模生产，而是可能推迟到 2027 年发布。</strong>而该消息也与 Jeff Pu 于今年 3 月预测的类似，大号折叠屏产品会在 2027 年推出。</p> <p>而据彭博社记者 Mark Gurman 此前消息，苹果正在研发一款 20 英寸显示的可折叠 iPad，并预计 2028 年推出，分析师 Ross Young 则预计苹果在 2026 年或 2027 年推出一款类似平板电脑的可折叠设备。</p> <p>对于「似乎已经定版」2026 年推出的折叠屏 iPhone，Jeff Pu 则与大多数媒体保持一致：将于 2026 年推出。其还预测，苹果在即将推出的 iPhone 17 系列会展现出「有限的创新」，而折叠屏 iPhone 则是备受期待。</p> <section><img src="https://s3.ifanr.com/images/ep/common-images/da_gong_si.png!720" alt="大公司" referrerpolicy="no-referrer"></section> <h3>微信员工否认「调时间恢复过期文件」</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/eb66b1ec-60aa-40e9-81c8-521e334d7343.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>日前，博主「望月湖别发疯」发文称，微信内因未及时接收、点击的文件，在超过七天过期后，可通过调整手机系统日期的方式，令文件恢复正常（正常点开）。</p> <p>而在昨日凌晨，微信员工「客村小蒋」发文回应称<strong>「这说法假的有点离谱了」</strong>。</p> <p>小蒋解释称，微信并不使用用户手机本地时间进行文件校验，其次从没点过接收的文件「过期就是过期了」。</p> <p>小蒋还补充，<strong>「聊天里的图片、视频、文件的过期时间是 14 天，不是 7 天」</strong>，其认为，这可能是这个博主所谓的自己试过有用的原因。</p> <p>最后小蒋强调，「望月湖别发疯」的说法从头到尾都是错的，并提醒：</p> <blockquote><p>随意修改手机时间，可能会让你新保存到手机的图片、文件的排序发生混乱，这个操作也非常不建议尝试。</p></blockquote> <h3>OpenAI 工程师：本周令人兴奋</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/b067e4b7-a30f-4b7e-aef4-6e665ede80d1.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>今天凌晨，OpenAI 工程师 Steven Heidel 发文称，<strong>「这将会是令人兴奋的一周」</strong>。而据此前 the Verge 以及近日消息来看，GPT-5 有望在 8 月初亮相。</p> <p>据 The Verge 此前消息，OpenAI 预计将在本月推出 GPT-5。报道指出，GPT-5 依然会推出 mini 和 nano 两个版本，并且均通过 API 提供。</p> <p>近期，OpenAI CEO Sam Altman 也不断放出预告信息：曾公开分享自己对 GPT-5 使用体验时表示，感受到前所未有的「无能为力」；在近日公开了 GPT-5 的对话界面，并表示「很快进入 SaaS 的快时尚时代」。</p> <p>值得一提的是，Altman 在前日发文表示，<strong>「接下来几个月我们将推出大量新内容——新模型、新产品、新功能等等。」</strong></p> <p>ChatGPT 还在凌晨的时候宣布更新：新增休息提醒，令用户拥有更健康、更有目标的使用方式；更好地改善情绪和精神困扰；为个人决策提供指导；提供来自医生、研究人员和心理健康顾问的专家意见。</p> <p>另外，ChatGPT 负责人还在昨晚宣布，<strong>ChatGPT 有望在本周迎来 7 亿周活跃用户这一目标。而该目标相较于 3 月底的 5 亿增长了 40%。</strong></p> <h3>鸿蒙智行最贵车型：大定破万台</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/8faa9798-eb23-49b7-8a8f-68128f41a275.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>昨日，华为常务董事、终端 BG 董事长余承东发文宣布，<strong>尊界 S800 上市 67 天大定突破 10000 台。</strong>另据鸿蒙智行 8 月 1 日消息，尊界 S800 上市 50 天大定突破 8000 台。</p> <p>尊界 S800 于今年 5 月正式发布，以 70.8 万至 101.8 万元的售价成为鸿蒙智行目前最贵车型。</p> <p>据了解，尊界 S800 配备了投射型迎宾大灯、「迎宾光毯」车门灯、车内「星空顶」、双后排零重力座椅、手势车控等豪华配置。</p> <p>平台方面，尊界 S800 搭载了全新的「途灵龙行平台」，基于华为独创的全域融合架构打造，是业内首个自主智能数字底盘平台。华为还在尊界 S800 上首发了 800V 的「雪鸮」智能增程平台和超高密度的纯电平台。</p> <p>尊界 S800 具备道路预瞄能力。安全性上采用「天使座主动安全防护」，拥有高达 4 颗激光雷达等总计 32 个传感器。</p> <h3>小米开源声音理解大模型</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/3e849ecd-06f2-4e8a-ac79-fb142f2383e1.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>昨日，小米技术发文宣布，正式发布并全量开源其声音理解大模型 MiDashengLM-7B 模型。</p> <p>官方介绍，MiDashengLM-7B 基于 Xiaomi Dasheng 作为音频编码器和 Qwen2.5-Omni-7B Thinker 作为自回归解码器，通过创新的通用音频描述训练策略，实现了对语音、环境声音和音乐的统一理解。</p> <p>值得一提的是，<strong>MiDashengLM-7B 的声音理解性能在 22 个公开评测集上刷新多模态大模型最好成绩（SOTA），多个基准测试超越 Qwen2.5-Omni 7B 和 Kimi-Audio-Instruct 7B。</strong></p> <p>效率方面，<strong>MiDashengLM-7B 单样本推理的首 Token 延迟（TTFT）仅为业界先进模型的 1/4，同等显存下的数据吞吐效率是业界先进模型的 20 倍以上。</strong>官方表示，这种效率优势直接转化为实际部署效益，在同等硬件条件下可支持更多的并发请求量，降低计算成本。</p> <p>另外，MiDashengLM 训练数据 100% 来自公开数据集，涵盖五大类 110 万小时资源，包括语音识别、环境声音、音乐理解、语音副语言和问答任务等多项领域。</p> <p>小米表示，作为「人车家全生态」战略的关键技术，MiDashengLM 通过统一理解语音、环境声与音乐的跨领域能力，不仅能听懂用户周围发生了什么事情，还能分析发现这些事情的隐藏含义，提高用户场景理解的泛化性。</p> <p>GitHub 主页：<a href="https://github.com/xiaomi-research/dasheng-lm">https://github.com/xiaomi-research/dasheng-lm</a></p> <p>技术报告：<a href="https://github.com/xiaomi-research/dasheng-lm/tree/main/technical_report">https://github.com/xiaomi-research/dasheng-lm/tree/main/technical_report</a></p> <p>模型参数（Hugging Face）：<a href="https://huggingface.co/mispeech/midashenglm-7b">https://huggingface.co/mispeech/midashenglm-7b</a></p> <p>模型参数（魔搭社区）：<a href="https://modelscope.cn/models/midasheng/midashenglm-7b">https://modelscope.cn/models/midasheng/midashenglm-7b</a></p> <p>网页 Demo： <a href="https://xiaomi-research.github.io/dasheng-lm">https://xiaomi-research.github.io/dasheng-lm</a></p> <p>交互 Demo：<a href="https://huggingface.co/spaces/mispeech/MiDashengLM">https://huggingface.co/spaces/mispeech/MiDashengLM</a></p> <h3>Anthropic 新技术：控制模型的性格特征</h3> <p>近年来，不少厂商的 AI 模型出现类似人类的「个性」和「情绪」，但这些特征常常变化不定，甚至突如其来。同时，这种「个性」波动的原因在于 AI 模型内部的行为模式尚未完全被理解。</p> <p>为了解决上述问题，Anthropic 团队日前提出了「persona vectors」（人格向量）的概念。</p> <p>「人格向量」是神经网络中反映个性特征的激活模式，类似人类大脑在不同情绪下的反应。通过分析这些人格向量，开发者可以更好地理解和控制 AI 模型的行为特征。</p> <p>据悉，人格向量有几个重要应用：</p> <ul> <li>可以帮助监控模型个性变化，避免模型朝着不良方向偏移；</li> <li>在训练过程中，人格向量可用于防止模型从数据中学习不良行为，例如「邪恶」或「阿谀奉承」等特征；</li> <li>人格向量还可用来识别训练数据中可能引发不良行为的部分。</li> </ul> <p>据研究表明，人格向量能够有效调节 AI 模型的个性变化，确保模型与人类价值观保持一致。通过这些向量，AI 模型的个性可以得到更精确的控制，从而避免不良行为的产生。</p> <h3>阿里通义语音大牛被曝转投京东</h3> <p>据公众号「申妈的朋友圈」援引知情人士消息，<strong>原阿里通义千问语音团队负责人，原腾讯 AI Lab 副主任鄢志杰已经加入京东探索研究院</strong>，担任语音实验室负责人，向京东集团副总裁、探索研究院院长何晓冬汇报。</p> <p>报道称，今年 2 月，鄢志杰以阿里通义团队语音算法负责人（P10 职级）的身份离职，当时的报道并未透露他的去向，后经多方确认，确定他加入腾讯 AI Lab，担任副主任。但在工作约三个月后，鄢志杰离职。</p> <p>据公开资料显示，鄢志杰于 2003 年升入中科大语音实验室，攻读博士学位，师从语音领域专家王仁华教授（科大讯飞创始人之一）。2008 年在中国科学技术大学语音实验室获博士学位之后，至 2015 年在微软亚洲研究院语音组任主管研究员。研究领域主要包括语音识别、语音合成、声纹、语音交互、手写及光学字符识别等。</p> <p>值得一提的是，鄢志杰于 2015 年加入阿里巴巴后，曾担任阿里 IDST（报道称其为达摩院前身）智能语音交互团队总监。后在 2017 年 10 月，达摩院成立后，鄢志杰担任达摩院机器智能语音实验室负责人，成为十三位「扫地僧」之一（最初的核心成员）。</p> <h3>腾讯混元开源多款小尺寸模型</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/b350d592-4b93-4428-91e9-a1dd205f8465.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>8 月 4 日，腾讯混元宣布开源四款小尺寸模型，参数分别为 0.5B、1.8B、4B、7B，消费级显卡即可运行，适用于笔记本电脑、手机、智能座舱、智能家居等低功耗场景，且支持垂直领域低成本微调。</p> <p>据介绍，新开源的 4 个模型属于融合推理模型，具备推理速度快、性价比高的特点，用户可根据使用场景灵活选择模型思考模式——快思考模式提供简洁、高效的输出；而慢思考涉及解决复杂问题，具备更全面的推理步骤。</p> <p>性能表现上，4 个模型均实现了跟业界同尺寸模型的对标，特别是在语言理解、数学、推理等领域有出色表现，在多个公开测试集上得分达到了领先水平。</p> <p><strong>值得一提的是，4 个模型亮点在于 Agent 和长文能力：</strong></p> <ul> <li>提升了模型在任务规划、工具调用和复杂决策以及反思等 agent 能力上的表现。</li> <li>模型原生长上下文窗口达到了 256k。</li> </ul> <p>目前，四个模型均在 Github 和 HuggingFace 等开源社区上线，Arm、高通、Intel、联发科技等多个消费级终端芯片平台也都宣布支持部署。</p> <h3>💡 Anthropic CEO：AI 问题现阶段已经无法回避</h3> <p>日前，Anthropic CEO Dario Amodei 接受了《Big Technology》播客的访谈，在谈话中，他详细阐述了过去几个月里几个关键决策背后的思考。</p> <p>Dario 指出，AI 模型的能力已经不再停留在「聪明的初中生」阶段，而是已经迈向了「能够解答博士级难题」的水平。这一进步并非偶然，而是规模法则推动的必然结果。</p> <p>Dario 确信，随着技术的加速发展，<strong>AI 正经历着一次前所未有的结构性变革，这个变革不仅临近，而且是不可避免的。</strong></p> <p>针对行业内的「收益递减」论调，Dario 表示，这一观点并不成立。他以自家 Claude 模型的表现为例，指出该模型在代码生成上的能力持续提升，且市场对其需求也在指数级增长。</p> <p>他强调，在大多数情况下，随着技术规模化，AI 能力的提升不会停止，反而会呈现出更加迅猛的趋势。<strong>「目前的进展完全符合我们对规模化的预期，技术增长没有减缓的迹象。」</strong></p> <p><strong>谈到 AI 风险时，Dario 强烈认为，这不是未来才需要担忧的问题，而是现阶段已变得无法回避的现实。</strong>他明确指出，AI 的发展带来的挑战，不仅仅是技术的强大本身，更重要的是如何在其发展过程中确保安全性和可控性，避免其带来潜在的社会风险。</p> <p>他认为，未来的关键在于如何管理和控制这些技术，防止它们在没有适当监督的情况下影响社会稳定。</p> <section><img src="https://s3.ifanr.com/images/ep/common-images/hao_chan_pin.png!720" alt="新产品" referrerpolicy="no-referrer"></section> <h3>Bose 推出 SoundLink Plus 蓝牙扬声器</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/9a8dbdf4-f4ff-427d-92b3-a1ca9157affe.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>8 月 4 日，<strong>Bose 宣布推出 Bose SoundLink Plus 蓝牙扬声器，扩展了其广受好评的 SoundLink 蓝牙扬声器系列。</strong></p> <p>据介绍，SoundLink Plus 新品将澎湃音质、坚固耐用、适配各种场景的设计融为一体，机身尺寸足以呈现震撼低音，同时兼具便携性，可轻松放入背包或沙滩包中。</p> <p>SoundLink Plus 采用全新声学构造：配备 1 个低音单元、1 个高音单元及 4 个被动振膜。同时，新品兼具抗震与防锈特性，并通过 IP67 等级防尘防水认证。</p> <p>另外，<strong>Bose 同时预告了其热门产品 Bose SoundLink Micro 蓝牙扬声器的二代机型。</strong>其凭借单体驱动单元与两片被动振膜配置，仍可实现超越体积的澎湃声量、清晰音质及饱满低频表现；并且同样通过 IP67 等级防护认证。</p> <p>价格方面，Bose SoundLink Plus 提供经典黑、暮色蓝及限量版沁柠黄三款配色，售价 2499 元；SoundLink Micro 蓝牙扬声器 II 将推出经典黑与暮色蓝两款配色，售价 999 元，预计夏末上市。</p> <h3>阿里通义发布全新文生图模型</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/5b612581-cbe3-41c5-8652-2a71e337bbf7.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>昨晚，阿里通义正式发布千问系列中首个图像生成基础模型 Qwen-Image，其在复杂文本渲染和精确图像编辑方面取得了显著进展。</p> <p><strong>官方介绍，Qwen-Image 的主要特性包括：</strong></p> <ul> <li>卓越的文本渲染能力: Qwen-Image 在复杂文本渲染方面表现出色，支持多行布局、段落级文本生成以及细粒度细节呈现。无论是英语还是中文，均能实现高保真输出。</li> <li>一致性的图像编辑能力: 通过增强的多任务训练范式，Qwen-Image 在编辑过程中能出色地保持编辑的一致性。</li> <li>强大的跨基准性能表现: 在多个公开基准测试中的评估表明，Qwen-Image 在各类生成与编辑任务中均获得 SOTA，是一个强大的图像生成基础模型。</li> </ul> <p><strong>目前，Qwen-Image 已上架 QwenChat 并已在魔搭社区与 Hugging Face 开源。</strong></p> <p>ModelScope：<a href="https://modelscope.cn/models/Qwen/Qwen-Image">https://modelscope.cn/models/Qwen/Qwen-Image</a></p> <p>Hugging Face：<a href="https://huggingface.co/Qwen/Qwen-Image">https://huggingface.co/Qwen/Qwen-Image</a></p> <p>GitHub：<a href="https://github.com/QwenLM/Qwen-Image">https://github.com/QwenLM/Qwen-Image</a></p> <p>Technical report：<a href="https://qianwen-res.oss-cn-beijing.aliyuncs.com/Qwen-Image/Qwen_Image.pdf">https://qianwen-res.oss-cn-beijing.aliyuncs.com/Qwen-Image/Qwen_Image.pdf</a></p> <p>Demo: <a href="https://modelscope.cn/aigc/imageGeneration?tab=advanced">https://modelscope.cn/aigc/imageGeneration?tab=advanced</a></p> <h3>高德地图 2025 发布：内置生活智能体</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/aadb8de8-27dd-47cd-8a89-3d4b6d2b717e.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>昨日，高德地图正式发布其全面 AI 化新版「高德地图 2025」。</p> <p>官方介绍，高德地图 2025 是全球首个基于地图的 AI Native（AI 原生）应用：</p> <blockquote><p>基于空间智能架构，融合超 20 年的物理世界数据生产和技术积累，孵化出具备自主推理能力的出行生活智能体「小高老师」，可实现「行前-行中-行后」全旅程 AI 服务。</p></blockquote> <p>具体来看，高德地图 2025 通过调用与通义共建的多元大模型簇，让高德智能体小高老师具备自主推理、计划、反思和行动能力，并通过调用出行服务、生活服务、空间服务等子智能体和工具链，因时因地为用户制定个性化的最优出行方案。</p> <p>目前，用户可以打开升级后的 APP，点击搜索栏里的语音图标，或者点击首页下方的「对话」，即可与小高老师开启自然交流。</p> <p>另外，<strong>高德地图 2025 出行服务智能体中的「AI 领航」，可实现「超视距感知」</strong>：不仅看到眼前路况，更能预判前方数公里的事故、拥堵、车道变化；高速上自动推荐最优车道，夜间弯道提前预警来车风险，变道决策更智能，行车盲区被逐一填补。</p> <h3>智己新一代 LS6 将提供超级增程版</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/d0e8d903-2892-446c-a77c-19ec364527b6.jpeg!720" alt="" referrerpolicy="no-referrer"></p> <p>8 月 4 日，智己汽车正式宣布，旗下新一代智己 LS6 将于 8 月 15 日进行全球首发，并且新车还将成为智己首款超级增程车型，定位「超级大五座智能 SUV」。</p> <p>其他方面，新车将配备新一代灵蜥数字底盘，拥有更智能化的出行体验，并且配备号称「完美复刻阿联酋头等舱」的「超级右排」。</p> <p>外观方面，新车采用了全新的外观设计，前脸采用 T 字型头灯，前保险杠配备了新的进气开口，尾部则依然采用小鸭尾+贯穿式尾灯（或继续支持智慧灯语）。</p> <p><strong>新一代 LS6 所搭载的「恒星」超级增程将配备最大 66kWh 的增程专属电池</strong>，纯电最长续航可达 450+km，<strong>综合续航可达 1500+km</strong>，最低油电综合能耗为 2.07L/100km（亏电油耗最低达 5.32L/100km），拥有 800V 超快充高压平台。</p> <h3>DJI Mini 5 Pro 曝光：搭载一英寸传感器</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/0858d9e2-9353-41f6-87ba-68363e119164.jpeg!720" alt="" referrerpolicy="no-referrer"></p> <p>据网友「AnhKiet」日前消息，DJI Mini 5 Pro 的包装疑似曝光。</p> <p>从「AnhKiet」透露的图片来看，DJI Mini 5 Pro 或将配备一英寸影像传感器，支持 4K/120fps 视频录制，提供 48mm 高品质中焦模式，并且云台还支持垂直拍摄和 225° 云台旋转。</p> <p>另外，从曝光的图片可以看出，DJI Mini 5 Pro 支持单块电池最长 36 分钟的续航，提供 ActiveTrack 360°、航点、巡航控制、高级跟随、激光辅助探测与测距（LADAR）等功能。</p> <section><img src="https://s3.ifanr.com/images/ep/common-images/pin_pai.png!720" alt="新消费" referrerpolicy="no-referrer"></section> <h3>喜茶海外最新成绩：门店一年暴增 6 倍</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/39e99d9d-6017-4fc4-ac0d-a007f8845a53.jpeg!720" alt="" referrerpolicy="no-referrer"></p> <p>喜茶日前宣布，当地时间 8 月 1 日，其位于美国加利福尼亚州库比蒂诺（Cupertino）Main Street 的门店正式营业。</p> <p>目前，<strong>喜茶海外市场门店总数已超过 100 家。</strong>过去一年，喜茶海外门店数量增长超过 6 倍，在美国市场更是实现了从 2 家到 30 余家的快速增长，成为在美发展最快、门店最多的新茶饮品牌，喜茶海外业务已进入快速发展阶段。</p> <p>截至目前，<strong>喜茶已进入新加坡、英国、加拿大、澳大利亚、马来西亚、美国、韩国、日本共 8 个海外国家和中国港澳地区，覆盖 28 个海外城市。</strong></p> <p>值得一提的是，作为硅谷心脏地带，库比蒂诺不仅是全球科技与创新的象征，也是苹果等世界级科技公司总部所在地。此次库比蒂诺新店的开业，也使喜茶成为首个进驻苹果总部所在地的新茶饮品牌。</p> <p>喜茶还推出了全新限定饮品「iYerba」，以「Think Awake」为灵感，将三种超级植物——马黛茶、羽衣甘蓝、奇亚籽注入一杯能量冰沙，传递来自南美的自然觉醒能量。</p> <h3>lululemon「夏日乐挑战」深圳站开赛</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/5939b6c8-47ec-4a00-b888-e1baaeeb98f4.jpeg!720" alt="" referrerpolicy="no-referrer"></p> <p>8 月 2 日，运动生活方式品牌 lululemon 2025 年「夏日乐挑战」区域进阶赛深圳站于福田星河 COCO Park 活力开赛。</p> <p>据悉，本次活动从深圳门店赛优胜的 7 支精英队伍齐聚现场，经过 5 项兼具挑战与趣味的项目比拼，最终「童虎带队」队凭借出色表现和团队默契晋级全国总决赛。</p> <p>作为 lululemon 品牌的标志性年度社区盛事，这场充满活力的「热汗运动会」再次登陆深圳。继 2021 年和 2023 年作为全国总决赛收官之战，lululemon 再度以创新的赛制和丰富的体验联动当地运动爱好者，点燃全民健身的热情，赋能城市运动活力。</p> <p>恰逢十五运会即将到来，深圳的体育氛围持续升温。lululemon 将星河 COCO Park 露天广场打造为向公众开放的「热汗大道」，设有「大小乒乓赛」「网球大满贯」「挥杆大挑战」等数余个趣味互动。三位 lululemon 社区好友还带领市民尽情舞动，跟随音乐节奏挥洒热汗，将夏日的氛围推向高潮。</p> <p>至今，2025 年「夏日乐挑战」已赛程过半，西安、厦门、上海、深圳、大连五大赛区相继收官。未来一周，南京、武汉、北京三座城市将展开区域冠军的角逐。最终，八支优胜队伍将会师成都，全力冲击全国总决赛。</p> <h3>宜家入驻京东，官方旗舰店将于 8 日开业</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/cddbb39d-f975-444a-956b-39ce5c35fa50.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>8 月 4 日，宜家中国与京东正式宣布，前者将入驻后者平台，宜家家居京东官方旗舰店将于 8 月 8 日开业。</p> <p>宜家方面表示，此次上线标志着宜家中国全渠道生态系统布局的持续拓展与深化。作为宜家在中国市场的全新线上触点，<strong>宜家家居京东官方旗舰店将覆盖 168 个品类、6500 余种产品，支持物流配送与会员服务。</strong></p> <p>开业期间，宜家京东官方旗舰店将带来 BÄSTBOLL 贝斯博尔电竞椅和 MÅLOMRÅDE 摩罗姆罗电竞桌两款新品全渠道首发，以及限时体验及丰富的灵感搭配。</p> <p>未来，宜家还将持续优化在京东平台的运营与服务体验，进一步拓展产品覆盖范围，共同为消费者打造更贴合实际需求的家居解决方案。</p> <section><img src="https://s3.ifanr.com/images/ep/common-images/hao_kan_de.png!720" alt="好看的" referrerpolicy="no-referrer"></section> <h3>电影《爱的暂停键》定档 9 月</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/42d19939-0294-45b3-bd6d-dd3b2402c777.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>昨日，电影《爱的暂停键》宣布定档 9 月 5 日上映。</p> <p>该片讲述了在丈夫提出离婚后，不敢放手的玛丽亚强拉着丈夫进行婚姻谘商，试图修复彼此之间的裂痕，当过去相处点滴被放大检视，这个关于情感的练习题，却比她想像中还要难解的故事。</p> <p>影片由莉莉娅·英戈尔夫斯多蒂尔自编自导，赫尔加·古莲主演，此前于 2024 年 7 月 2 日在捷克卡罗维发利国际电影节首映。</p> <p>值得一提的是，影片于今年获得第 15 届北京国际电影节天坛奖最佳影片，莉莉娅·英戈尔夫斯多蒂尔凭借该片获得最佳导演、最佳编剧，赫尔加·古莲凭借该片获得最佳女主角。</p> <h3>《刺杀小说家 2》10 月上映</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/8c5071fa-c6f9-45e8-a3b9-2999e0123a00.jpeg!720" alt="" referrerpolicy="no-referrer"></p> <p>8 月 4 日，电影《刺杀小说家 2》官宣定档 10 月 1 日。</p> <p>该片讲述了小说家路空文陷入低谷欲毁掉小说《弑神》，其小说中主角空文反抗命运，最终路空文找回信念，与书中人一起化解了双世界危机的故事。</p> <p>影片由里则林编剧，路阳执导，邓超、董子健、雷佳音等主演。</p> <h3>曹保平执导，《脱缰者也》提档至 8 月 23 日</h3> <p><img src="https://s3.ifanr.com/images/ep/uploads/8.5_%E6%97%A9%E6%8A%A5/172c9c26-e48a-4763-b211-6a2a4b05d870.jpg!720" alt="" referrerpolicy="no-referrer"></p> <p>昨日，由曹保平执导的天津喜剧电影《脱缰者也》宣布提档至 8 月 23 日。</p> <p>该片讲述了世纪之交，背井离乡的马飞重返天津，在种种不尽如意的遭遇下「拐走」外甥李嘉文，舅甥就此踏上一段「离经叛道」之旅。</p> <p>影片由曹保平执导，郭麒麟、齐溪、孙安可、常远等主演。值得一提的是，2025 年 6 月，曹保平凭借该片获得第 27 届上海国际电影节金爵奖主竞赛单元最佳导演。</p>
        """
}

#Preview {
    WebKitDemoView()
}
