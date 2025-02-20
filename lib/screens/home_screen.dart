import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zhaopingapp/services/dio_client.dart';

import '../models/job.dart';
import '../widgets/job_card.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _subTabController;

  List<String> _keywords = []; // 动态关键词列表
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: _keywords.length, vsync: this);
    _subTabController = TabController(length: 3, vsync: this);
    _fetchKeywords();
  }

  Future<void> _fetchKeywords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await dio.get("getKeywords");
      // 判断返回数据是否正确
      if (response.statusCode == 200 &&
          response.data['code'] == 200 &&
          response.data['date'] is List) {
        _keywords = response.data['date'].cast<String>();
        _mainTabController =
            TabController(length: _keywords.length, vsync: this);
        _subTabController = TabController(length: 3, vsync: this);
      }
    } on DioException catch (e) {
      _errorMessage = '请求异常 ${e.message}';
      if (e.response != null) {
        _errorMessage = '请求异常 ${e.response!.statusCode} ${e.response!.data}';
      }
      // 在请求失败时设置默认的关键词数据
      _keywords = [
        '技术开发',
        '产品运营',
        '设计创意',
        '市场营销',
        '人力资源',
        '金融财务',
        '教育培训',
        '医疗健康'
      ];
      _mainTabController = TabController(length: _keywords.length, vsync: this);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _mainTabController,
          isScrollable: true, // 允许滚动
          tabs: _keywords.map((keyword) => Tab(text: keyword)).toList(),
          onTap: (index) {
            // 当主 Tab 切换时，重置子 Tab 到第一个
            _subTabController.index = 0;
          },
        ),
        TabBar(
          controller: _subTabController,
          tabs: const [
            Tab(text: '推荐'),
            Tab(text: '附近'),
            Tab(text: '最新'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              // 推荐
              JobList(jobs: _generateSampleJobs()),
              // 附近
              JobList(jobs: _generateSampleJobs()),
              // 最新
              JobList(jobs: _generateSampleJobs()),
            ],
          ),
        ),
      ],
    );
  }

  // 生成示例数据
  List<Job> _generateSampleJobs() {
    final titles = [
      '高级Java开发工程师',
      'Flutter移动开发工程师',
      'Python数据分析师',
      '前端开发工程师',
      'DevOps工程师',
      '产品经理',
      'UI设计师',
      '算法工程师',
      '测试工程师',
      '运维工程师'
    ];

    final companies = [
      {'name': '字节跳动', 'size': '10000人以上'},
      {'name': '腾讯科技', 'size': '10000人以上'},
      {'name': '阿里巴巴', 'size': '10000人以上'},
      {'name': '美团点评', 'size': '10000人以上'},
      {'name': '快手科技', 'size': '5000-10000人'},
      {'name': '小米科技', 'size': '5000-10000人'},
      {'name': '京东集团', 'size': '10000人以上'},
      {'name': '网易', 'size': '5000-10000人'},
      {'name': '百度', 'size': '10000人以上'},
      {'name': '滴滴出行', 'size': '5000-10000人'}
    ];

    final salaries = [
      '15k-25k',
      '20k-35k',
      '25k-45k',
      '30k-50k',
      '35k-60k',
      '40k-70k',
      '45k-80k',
      '50k-90k',
      '60k-100k',
      '面议'
    ];

    final locations = [
      '北京市朝阳区',
      '上海市浦东新区',
      '深圳市南山区',
      '广州市天河区',
      '杭州市西湖区',
      '成都市高新区',
      '武汉市洪山区',
      '南京市江宁区',
      '西安市雁塔区',
      '苏州市工业园区'
    ];

    final allTags = {
      '开发': ['Java', 'Spring Boot', 'MySQL', 'Redis', 'MQ', 'Flutter', 'Python', 'Django', 
              'React', 'Vue.js', 'Node.js', 'TypeScript', 'Docker', 'K8s', 'AWS'],
      '设计': ['UI设计', 'UE设计', 'Figma', 'Sketch', 'PhotoShop', '原型设计', '交互设计'],
      '产品': ['需求分析', '产品规划', '用户研究', '数据分析', 'Axure', '项目管理'],
      '算法': ['机器学习', '深度学习', 'NLP', '计算机视觉', 'PyTorch', 'TensorFlow']
    };

    final hrNames = ['王女士', '李先生', '张女士', '刘先生', '陈女士', '赵先生', '孙女士', '周先生', '吴女士', '郑先生'];

    return List.generate(10, (index) {
      final company = companies[index];
      final title = titles[index];
      String category = '';
      if (title.contains('开发')) category = '开发';
      else if (title.contains('设计')) category = '设计';
      else if (title.contains('产品')) category = '产品';
      else if (title.contains('算法')) category = '算法';
      else category = '开发';

      final tagPool = allTags[category] ?? allTags['开发']!;
      final selectedTags = (tagPool.toList()..shuffle()).take(3).toList();

      return Job(
        title: title,
        salary: salaries[index],
        company: company['name']!,
        companySize: company['size']!,
        tags: selectedTags,
        hrName: hrNames[index],
        location: locations[index]
      );
    });
  }
}
