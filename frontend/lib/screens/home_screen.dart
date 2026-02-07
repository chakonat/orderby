import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restaurant.dart';
import '../state/app_state.dart';
import '../widgets/formatters.dart';
import 'profile_screen.dart';
import 'restaurant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().loadHome();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Restaurant> _filterRestaurants(List<Restaurant> items, String? category) {
    if (category == null || category == 'Барлығы') return items;
    final lower = category.toLowerCase();
    return items.where((restaurant) {
      final tags = restaurant.tags.map((tag) => tag.toLowerCase());
      return tags.contains(lower) || restaurant.cuisine.toLowerCase() == lower;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final colors = Theme.of(context).colorScheme;
    final categoryList = ['Барлығы', ...state.categories];
    final filteredRestaurants = _filterRestaurants(state.restaurants, selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orderby'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }
              if (value == 'logout') {
                context.read<AppState>().logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Text(state.currentUser?.name ?? 'Профиль'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Выйти'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  state.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(color: colors.onPrimaryContainer, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _BackgroundLayer(colors: colors),
          RefreshIndicator(
            onRefresh: () => state.loadHome(query: _controller.text),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _HeroSection(colors: colors),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  onSubmitted: (value) => state.loadHome(query: value),
                  decoration: const InputDecoration(
                    hintText: 'Мейрамхана немесе тағам іздеу',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                if (state.isLoading)
                  const LinearProgressIndicator()
                else if (state.errorMessage != null)
                  _ErrorCard(message: state.errorMessage!)
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'Категориялар', action: 'Барлығы', onTap: () {
                        setState(() => selectedCategory = 'Барлығы');
                      }),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryList.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = categoryList[index];
                            final isSelected = category == (selectedCategory ?? 'Барлығы');
                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) => setState(() => selectedCategory = category),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(title: 'Ұсынылғандар', action: 'Жаңарту', onTap: () {}),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 190,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.promos.isEmpty ? featured.length : state.promos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (state.promos.isEmpty) {
                              final item = featured[index];
                              return _FeaturedCard(
                                item: PromoCardData(
                                  title: item.title,
                                  subtitle: item.subtitle,
                                  badge: item.badge,
                                  imageUrl: '',
                                  rating: item.rating,
                                  eta: item.eta,
                                  color: item.color,
                                ),
                              );
                            }

                            final promo = state.promos[index];
                            return _FeaturedCard(
                              item: PromoCardData(
                                title: promo.title,
                                subtitle: promo.subtitle,
                                badge: promo.badge,
                                imageUrl: promo.imageUrl,
                                rating: '${promo.discountPercent}% бонус',
                                eta: '15-25 мин',
                                color: colors.primary,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(title: 'Мейрамханалар', action: 'Картадан', onTap: () {}),
                      const SizedBox(height: 12),
                      if (filteredRestaurants.isEmpty)
                        const Text('Бұл категорияда ресторан жоқ')
                      else
                        ...filteredRestaurants.map((restaurant) => _RestaurantCard(
                              restaurant: restaurant,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RestaurantScreen(restaurant: restaurant),
                                  ),
                                );
                              },
                            )),
                      const SizedBox(height: 24),
                      _PromoBanner(colors: colors),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 12),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Төлем жүйелерін біріктіретін онлайн тағамға тапсырыс беру қолданбасы',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: const [
              _InfoPill(label: 'Kaspi • Bank card'),
              _InfoPill(label: 'Apple Pay • Google Pay'),
              _InfoPill(label: 'Жеткізу 24/7'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: TextStyle(color: colors.primary),
          ),
        )
      ],
    );
  }
}

class PromoCardData {
  const PromoCardData({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.imageUrl,
    required this.rating,
    required this.eta,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String badge;
  final String imageUrl;
  final String rating;
  final String eta;
  final Color color;
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.item});

  final PromoCardData item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            item.color,
            item.color.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: item.imageUrl.isNotEmpty
            ? DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover, opacity: 0.2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                item.badge,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            item.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            item.subtitle,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.star_rounded, color: colors.secondary, size: 18),
              const SizedBox(width: 4),
              Text(
                item.rating,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Text(
                item.eta,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant, required this.onTap});

  final Restaurant restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: colors.surfaceContainerHighest),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.description,
                          style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _Badge(label: restaurant.deliveryTime),
                            _Badge(label: restaurant.priceLevel),
                            _Badge(label: formatCurrency(restaurant.minOrder)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.star_rounded, color: colors.secondary, size: 18),
                  const SizedBox(width: 4),
                  Text(restaurant.rating.toStringAsFixed(1)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      restaurant.tags.join(' • '),
                      style: TextStyle(color: colors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Бірінші тапсырысқа -20%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                SizedBox(height: 6),
                Text(
                  'Kaspi және карта арқылы төлемде',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.local_offer_rounded, color: Colors.white),
        ],
      ),
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer({required this.colors});

  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF7F2EC),
            const Color(0xFFF7F2EC).withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -40,
            child: _BlurCircle(color: colors.secondaryContainer, size: 180),
          ),
          Positioned(
            left: -40,
            top: 220,
            child: _BlurCircle(color: colors.primaryContainer, size: 140),
          ),
          Positioned(
            right: -40,
            bottom: 120,
            child: _BlurCircle(color: colors.secondaryContainer, size: 160),
          ),
        ],
      ),
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(message),
    );
  }
}

class FeaturedItem {
  const FeaturedItem({
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.eta,
    required this.badge,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String rating;
  final String eta;
  final String badge;
  final Color color;
}

const featured = [
  FeaturedItem(
    title: 'Kaspi Pay кешбэк',
    subtitle: 'Әр тапсырысқа 5% бонус',
    rating: '4.9',
    eta: '15-25 мин',
    badge: 'Апта ұсынысы',
    color: Color(0xFF1E5C4F),
  ),
  FeaturedItem(
    title: 'Steppe Pizza',
    subtitle: '2 пицца + сусын',
    rating: '4.8',
    eta: '20-30 мин',
    badge: 'Combo',
    color: Color(0xFF9C4A2F),
  ),
  FeaturedItem(
    title: 'Saryarka Sushi',
    subtitle: 'Жаңа роллдар тізімі',
    rating: '4.7',
    eta: '35-45 мин',
    badge: 'New',
    color: Color(0xFF3E6B6B),
  ),
];
