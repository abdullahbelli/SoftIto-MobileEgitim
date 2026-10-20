import 'package:flutter/material.dart';
import '../../../filizora/lib/core/constants/app_colors.dart';
import '../../../filizora/lib/core/extensions/context_extensions.dart';

/// Örnek Referans Ekranı (Mimari ve Kodlama Standartları Şablonu)
///
/// DİKKAT: Bu dosya yalnızca `.agents/skills/examples/` klasöründe yer alan
/// bir geliştirici kılavuzudur. Gerçek uygulama ekranlarıyla karıştırılmamalıdır.
class SampleScreen extends StatelessWidget {
  const SampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Örnek Standart Ekran'),
        actions: const [_SampleHelpButton()],
      ),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SampleHeaderSection(),
              SizedBox(height: 16),
              _SampleCardSection(),
              Spacer(),
              _SampleActionButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SampleHelpButton extends StatelessWidget {
  const _SampleHelpButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline),
      tooltip: 'Yardım',
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu bir örnek ekrandır.')),
        );
      },
    );
  }
}

class _SampleHeaderSection extends StatelessWidget {
  const _SampleHeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Örnek Başlık',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bu bileşen 40 satırı aşmayan build kuralına uygun bölünmüştür.',
          style: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SampleCardSection extends StatelessWidget {
  const _SampleCardSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.oceanBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Material 3 kartı ve Filizora tema renkleri doğru şekilde kullanılmıştır.',
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleActionButton extends StatelessWidget {
  const _SampleActionButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Örnek Buton'),
      ),
    );
  }
}
