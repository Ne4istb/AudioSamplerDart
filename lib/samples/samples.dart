class SamplesLib {
  static final _samples = new SamplesLib._internal();

  factory SamplesLib() {
    return _samples;
  }

  SamplesLib._internal();

  List<SampleItem> get list => [
        new SampleItem('Beat 00', 'samples/beat.ogg'),
        new SampleItem('Beat 01', 'samples/beat01.ogg'),
        new SampleItem('Beat 02', 'samples/beat02.ogg'),
        new SampleItem('Beat 03', 'samples/beat03.ogg'),
        new SampleItem('Beat 04', 'samples/beat04.ogg'),
        new SampleItem('Beat 05', 'samples/beat05.ogg'),
        new SampleItem('Beat 06', 'samples/beat06.ogg'),
        new SampleItem('Beat 07', 'samples/beat07.ogg'),
        new SampleItem('Beat 08', 'samples/beat08.ogg'),
        new SampleItem('Beat 09', 'samples/beat09.ogg'),
        new SampleItem('Beat 10', 'samples/beat10.ogg'),
        new SampleItem('Keys 00', 'samples/keys01.ogg'),
        new SampleItem('Keys 01', 'samples/keys02.ogg'),
        new SampleItem('Keys 02', 'samples/keys03.ogg'),
        new SampleItem('Keys 03', 'samples/keys04.ogg'),
        new SampleItem('Keys 04', 'samples/keys05.ogg'),
        new SampleItem('Keys 05', 'samples/keys06.ogg'),
        new SampleItem('Keys 06', 'samples/keys07.ogg'),
        new SampleItem('Keys 07', 'samples/keys08.ogg'),
        new SampleItem('Jungle', 'samples/jungle.ogg'),
        new SampleItem('Bass 00', 'samples/bass.ogg'),
        new SampleItem('Bass 01', 'samples/bass01.ogg'),
        new SampleItem('Bass 02', 'samples/bass02.ogg'),
        new SampleItem('Bass 03', 'samples/bass03.ogg'),
        new SampleItem('Bass 04', 'samples/bass04.ogg'),
        new SampleItem('Bass 05', 'samples/bass05.ogg'),
        new SampleItem('Bass 06', 'samples/bass06.ogg'),
        new SampleItem('Bass 07', 'samples/bass07.ogg'),
        new SampleItem('Bass 08', 'samples/bass08.ogg'),
        new SampleItem('Bass 09', 'samples/bass09.ogg'),
        new SampleItem('Bass 10', 'samples/bass10.ogg'),
        new SampleItem('Guitar 00', 'samples/guitar.ogg'),
        new SampleItem('Guitar 01', 'samples/guitar01.ogg'),
        new SampleItem('Guitar 02', 'samples/guitar02.ogg'),
        new SampleItem('Guitar 03', 'samples/guitar03.ogg'),
        new SampleItem('Guitar 04', 'samples/guitar04.ogg'),
        new SampleItem('Guitar 05', 'samples/guitar05.ogg'),
        new SampleItem('Guitar 06', 'samples/guitar06.ogg'),
        new SampleItem('Guitar 07', 'samples/guitar07.ogg'),
        new SampleItem('Guitar 08', 'samples/guitar08.ogg'),
        new SampleItem('Guitar 09', 'samples/guitar09.ogg'),
        new SampleItem('Guitar 10', 'samples/guitar10.ogg'),
        new SampleItem('Effect 00', 'samples/fx00.ogg'),
        new SampleItem('Effect 01', 'samples/fx01.ogg'),
        new SampleItem('Effect 02', 'samples/fx02.ogg'),
        new SampleItem('Effect 03', 'samples/fx03.ogg'),
        new SampleItem('Effect 04', 'samples/fx04.ogg'),
        new SampleItem('Effect 05', 'samples/fx05.ogg'),
        new SampleItem('Effect 06', 'samples/fx06.ogg'),
        new SampleItem('Effect 07', 'samples/fx07.ogg'),
        new SampleItem('Effect 08', 'samples/fx08.ogg'),
        new SampleItem('Effect 09', 'samples/fx09.ogg'),
        new SampleItem('Effect 10', 'samples/fx10.ogg')
      ];
}

class SampleItem {
  String name;
  String href;

  SampleItem(this.name, this.href);
}
