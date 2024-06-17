export default function NavBar({ children }: { children: React.ReactNode }) {
  return (
    <footer className="flex justify-center bg-primary text-white">
      <div className="flex w-page items-center justify-around space-x-4">{children}</div>
    </footer>
  );
}
