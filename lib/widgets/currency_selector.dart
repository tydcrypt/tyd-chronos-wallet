import 'package:flutter/material.dart';
import '../services/currency_service.dart';

class CurrencySelector extends StatefulWidget {
  final Function(String)? onCurrencyChanged;
  final bool isCompact;

  const CurrencySelector({
    Key? key,
    this.onCurrencyChanged,
    this.isCompact = false,
  }) : super(key: key);

  @override
  _CurrencySelectorState createState() => _CurrencySelectorState();
}

class _CurrencySelectorState extends State<CurrencySelector> {
  String _selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
  }

  Future<void> _loadSelectedCurrency() async {
    final currency = await CurrencyService.getSelectedCurrency();
    setState(() {
      _selectedCurrency = currency;
    });
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Currency'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: CurrencyService.currencySymbols.keys.length,
              itemBuilder: (context, index) {
                final currencyCode = CurrencyService.currencySymbols.keys.elementAt(index);
                return ListTile(
                  leading: Text(
                    CurrencyService.getCurrencySymbol(currencyCode),
                    style: TextStyle(fontSize: 20),
                  ),
                  title: Text(CurrencyService.getCurrencyName(currencyCode)),
                  subtitle: Text(currencyCode),
                  trailing: currencyCode == _selectedCurrency
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    _selectCurrency(currencyCode);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectCurrency(String currencyCode) async {
    await CurrencyService.setSelectedCurrency(currencyCode);
    setState(() {
      _selectedCurrency = currencyCode;
    });
    widget.onCurrencyChanged?.call(currencyCode);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return IconButton(
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyService.getCurrencySymbol(_selectedCurrency),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.arrow_drop_down, size: 16),
          ],
        ),
        onPressed: _showCurrencyDialog,
        tooltip: 'Change Currency',
      );
    }

    return OutlinedButton.icon(
      icon: Text(
        CurrencyService.getCurrencySymbol(_selectedCurrency),
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      label: Icon(Icons.arrow_drop_down),
      onPressed: _showCurrencyDialog,
    );
  }
}
