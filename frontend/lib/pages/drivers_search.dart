import 'dart:ui';
import 'package:f1_app/providers/driver_stats_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/searchPage_providers.dart';
import 'driver_details.dart';

class DriverSearchPage extends ConsumerWidget {
  const DriverSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // ── SEARCH FIELD ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: "SEARCH DRIVER...",
                hintStyle: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE10600)),
                ),
              ),
              onChanged: (value) {
                ref.read(queryProvider.notifier).state = value;
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── RESULTS ──
          const Expanded(child: DriversList()),
        ],
      ),
    );
  }
}

class DriversList extends ConsumerWidget {
  const DriversList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivers = ref.watch(filteredDriversProvider);

    if (drivers == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "LOADING DRIVERS",
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE10600)),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (drivers.isEmpty) {
      return const Center(
        child: Text(
          "NO DRIVERS FOUND",
          style: TextStyle(
            color: Colors.white38,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: drivers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final driver = drivers[index];

        return GestureDetector(
          onTap: (){
            ref.read(selectedDriverProvider.notifier).state = driver.driverId;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DriverCareerPage(
                  driverName: "${driver.givenName} ${driver.familyName}",
                  driverId: driver.driverId,
                  nationality: driver.nationality ?? '',
                  dateOfBirth: driver.dateOfBirth ?? '',
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    // ── RED ACCENT BAR ──
                    Container(
                      width: 3,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE10600),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 14),
          
                    // ── DRIVER INFO ──
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${driver.givenName} ${driver.familyName}",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            driver.nationality ?? "",
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.white38,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}